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
  include Redpear::Schema

  class << self

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
    #   Comment.scoped(123) # => "comments:123"
    #   Comment.scoped("[i1]", 123) # => "comments:[i1]:123"
    def scoped(*tokens)
      [scope, *tokens].join(':')
    end

    # @return [Redpear::Store::Set] the IDs of all existing records
    def members
      @_members ||= Redpear::Store::Set.new scoped("~"), connection
    end

    # @return [Redpear::Store::Counter] the generator of primary keys
    def pk_counter
      @_pk_counter ||= Redpear::Store::Counter.new scoped("+"), connection
    end

    # Runs a bulk-operation.
    # @yield operations that should be run in the transaction
    def transaction(&block)
      connection.transaction(&block)
    end

    # @return [Integer] the number of total records
    def count
      members.size
    end

    # @param [String] id the ID to check
    # @return [Boolean] true or false
    def exists?(id)
      !id.nil? && members.include?(id)
    end

    # @param [String] id the ID of the record to find
    # @return [Redpear::Model] a record, or nil when not found
    def find(id)
      instantiate(id) if exists?(id)
    end

    # @return [Array<Redpear::Model>] all records
    def all
      members.map &method(:find)
    end

    # @yield over each available record
    # @yieldparam [Redpear::Model] record
    def find_each
      members.each do |id|
        yield find(id)
      end
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
    self.class.members.add(id)
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
    value  = column.encode_value(value)

    case column
    when Redpear::Schema::Score
      column.members[id] = value
    when Redpear::Schema::Index
      column.members(value).add(id)
      attributes[column] = value
    when Redpear::Schema::Column
      attributes[column] = value
    end
    delete column.to_s
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

  # Expires the record.
  # @overload expire(time)
  #   @param [Time] time The time to expire the record at
  # @overload expire(number)
  #   @param [Integer] number Expire in `number` of seconds from now
  def expire(value)
    attributes.expire(value)
  end

  # @return [Integer] the period this record has to live.
  # May return nil for non-expiring records and non-existing records.
  def ttl
    attributes.ttl
  end

  # Bulk-updates the model
  # @return [Hash]
  def update(hash)
    self.class.transaction do
      bulk = {}
      hash.each do |name, value|
        column = self.class.columns[name] || next
        value  = column.encode_value(value)

        case column
        when Redpear::Schema::Score
          column.members[id] = value
        when Redpear::Schema::Index
          column.members(value).add(id)
          bulk[column] = value
        when Redpear::Schema::Column
          bulk[column] = value
        end
      end
      attributes.merge! bulk
    end

    clear
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
    @_attributes ||= Redpear::Store::Hash.new self.class.scoped('~', id), self.class.connection
  end

  # Return lookups, relevant to this record
  # @return [Array<Redpear::Store::Enumerable>] the lookups this record is related to
  def lookups
    @_lookups ||= [self.class.members] + self.class.columns.indicies.map {|i| i.for(self) }
  end

  # Destroy the record.
  # @return [Boolean] true if successful
  def destroy
    lookups # Build before transaction
    self.class.transaction do
      lookups.each {|l| l.delete(id) }
      attributes.purge!
    end
    true
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

  private :store, :fetch, :delete, :delete_if, :keep_if, :merge!, :reject!, :select!, :replace

end
