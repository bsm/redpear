require 'redpear'

=begin
Redis is a simple key/value store, hence storing structured data can be a
challenge. Redpear::Model allows you to store/find/associate "records" in a Redis
DB very efficiently, minimising IO operations and storage space where possible.

For example:

  class Post < Redpear::Model
    column :title
    column :body
  end

  class Comment < Redpear::Model
    column :body
    index :post_id
  end

Redpear::Model is VERY lightweight. It is optimised for raw speed at the
expense of convenience.
=end
class Redpear::Model < Hash
  autoload :Finders, 'redpear/model/finders'
  autoload :Expiration, 'redpear/model/expiration'

  include Redpear::Schema
  include Finders
  include Expiration

  class << self

    alias_method :create, :new

    # @param [Redpear::Connection] define a custom connection
    attr_writer :connection

    # @param [String] define a custom scope
    attr_writer :scope

    # @return [Redpear::Connection] the connection
    def connection
      @connection ||= (superclass.respond_to?(:connection) ? superclass.connection : Redpear::Connection.new)
    end

    # @return [String] the scope of this model. Example:
    #   Comment.scope # => "comments"
    def scope
      @scope ||= "#{name.split('::').last.downcase}s"
    end

    # @param [multiple] tokens
    #   The tokens to add to the scope
    # @return [String] the full scope.
    # Examples:
    #   Comment.nested_key(123) # => "comments:123"
    #   Comment.nested_key("abc", 123) # => "comments:abc:123"
    def nested_key(*tokens)
      [scope, *tokens].join(':')
    end

    # @return [Redpear::Store::Set] the IDs of all existing records
    def members
      @_members ||= Redpear::Store::Set.new nested_key(:~), connection
    end

    # @return [Redpear::Store::Counter] the generator of primary keys
    def pk_counter
      @_pk_counter ||= Redpear::Store::Counter.new nested_key(:+), connection
    end

    # Runs a bulk-operation.
    # @yield operations that should be run in the transaction
    def transaction(&block)
      connection.transaction(&block)
    end

    # Destroys a record. Example:
    # @param [String] id the ID of the record to destroy
    # @return [Redpear::Model] the destroyed record
    def destroy(id)
      instantiate(id).tap(&:destroy)
    end

    # Allocate an instance
    def instantiate(id)
      instance = allocate
      instance.send :store, 'id', id.to_s
      instance
    end
    private :instantiate

  end

  def initialize(attrs = {})
    super()
    store 'id', (attrs.delete("id") || attrs.delete(:id) || self.class.pk_counter.next).to_s
    update(attrs)
    after_create(attrs)
  end

  # @return [String] the ID of this record
  def id
    fetch 'id'
  end

  # Custom comparator, inspired by ActiveRecord::Base#==
  # @param [Object] other the comparison object
  # @return [Boolean] true, if +other+ is persisted and ID
  def ==(other)
    case other
    when Redpear::Model
      other.instance_of?(self.class) && other.id == id
    else
      super
    end
  end
  alias :eql? :==

  # Use ID as base for hash
  def hash
    id.hash
  end

  # Reads and (caches) a single value
  # @param [String] name
  #   The name of the attributes
  # @return [Object]
  #   The attribute value
  def [](name)
    return if frozen?

    column = self.class.columns[name]
    return super if column.nil? || key?(column)

    value = case column
    when Redpear::Schema::Score
      column.members[id]
    when Redpear::Schema::Column
      attributes[column]
    end

    store column, column.type_cast(value)
  end

  # Write a single attribute
  # @param [String] name
  #   The name of the attributes
  # @param [Object] value
  #   The value to store
  def []=(name, value)
    column = self.class.columns[name] || return
    delete column.to_s
    store_attribute attributes, column, value
  end

  # Increments the value of a counter attribute
  # @param [String] name
  #   The column name to increment
  # @param [Integer] by
  #   Increment by this value
  def increment(name, by = 1)
    column = self.class.columns[name]
    return false unless column && column.type == :counter

    store column, attributes.increment(column, by)
  end

  # Decrements the value of a counter attribute
  # @param [String|Symbol] name
  #   The column name to decrement
  # @param [Integer] by
  #   Decrement by this value
  def decrement(name, by = 1)
    increment name, -by
  end

  # Bulk-updates the model
  # @return [Hash]
  def update(hash)
    clear
    bulk = {}
    hash.each do |name, value|
      column = self.class.columns[name] || next
      store_attribute bulk, column, value
    end
    attributes.merge! bulk
    self
  end

  # Clear all the cached attributes, but keep ID
  # @return [Hash] self
  def clear
    value = self.id
    super
  ensure
    store 'id', value
  end

  # Returns the attributes store
  # @return [Redpear::Store::Hash] attributes
  def attributes
    @_attributes ||= Redpear::Store::Hash.new self.class.nested_key("", id), self.class.connection
  end

  # Return lookups, relevant to this record
  # @return [Array<Redpear::Store::Enumerable>] the lookups this record is related to
  def lookups
    @_lookups ||= [self.class.members] + self.class.columns.indicies.map {|i| i.for(self) }
  end

  # Destroy the record.
  # @return [Boolean] true if successful
  def destroy
    before_destroy
    self.class.transaction do
      lookups.each {|l| l.delete(id) }
      attributes.purge!
      after_destroy
    end
    freeze
  end

  # Show information about this record
  # @return [String]
  def inspect
    "#<#{self.class.name} #{super}>"
  end

  # Cache a key/value pair
  def store(key, value)
    super key.to_s, value
  end

  # Store an attribute in target
  def store_attribute(target, column, value)
    value = column.encode_value(value)

    case column
    when Redpear::Schema::Score
      column.members[id] = value    unless value.nil?
    when Redpear::Schema::Index
      column.members(value).add(id) unless value.nil?
      target[column] = value
    when Redpear::Schema::Column
      target[column] = value
    end

    value
  end

  # Cheap after create callback, override in subclasses and don't forget to
  # call `super()`.
  # @params [Hash] attrs attributes used on initialization
  def after_create(attrs)
    self.class.members.add(id)
  end

  # Cheap before destroy callback, override in subclasses and don't forget to
  # call `super()`.
  def before_destroy
    lookups # Build lookups
  end

  # Cheap after destroy callback, override in subclasses and don't forget to
  # call `super()`. Called within the transaction, be careful not to include
  # read opertions.
  def after_destroy
  end

  protected :store, :store_attribute, :after_create, :before_destroy, :after_destroy
  private   :fetch, :delete, :delete_if, :keep_if, :merge!, :reject!, :select!, :replace

end
