require "set"
require "redpear/core_ext/stringify_keys"

=begin
Redis is a simple key/value store, hence storing structured data can be a
challenge. Redpear allows you to store/find/associate "records" in a Redis DB
very efficiently, minimising IO operations and storage space where possible.

For example:

  class Post < Redpear::Model
    column :title
    column :body
  end

  class Comment < Redpear::Model
    column :body
    index :post_id
  end

Let's create a post and a comment:

  post = Post.save :title => "Hi!", :body => "I'm a new post"
  comment = Comment.save :post_id => post.id, :body => "I like this!"

Redpear is VERY lightweight. Compared with other ORMs, it offers raw speed at
the expense of convenience.
=end
class Redpear::Model < Hash
  include Redpear::Namespace
  include Redpear::Persistence
  include Redpear::Expiration
  include Redpear::Counters
  include Redpear::Schema
  include Redpear::Finders

  class << self

    attr_writer :connection

    # @return [Redpear::Connection] the connection
    def connection
      @connection ||= (superclass.respond_to?(:connection) ? superclass.connection : Redpear::Connection.new)
    end

  end

  # Ensure we can read raw level values
  alias_method :__fetch__, :[]

  def initialize(attrs = {})
    super()
    @__attributes__ = {}
    @__loaded__     = true
    update(attrs)
  end

  # Returns the ID of the record
  # @return [String]
  def id
    value = __fetch__("id")
    value.to_s if value
  end

  # ID accessor
  # @param [Object] id
  def id=(value)
    self["id"] = value.to_s
  end

  # Custom comparator, inspired by ActiveRecord::Base#==
  # @param [Object] other the comparison object
  # @return [Boolean] true, if +other+ is persisted and ID
  def ==(other)
    case other
    when Redpear::Model
      other.instance_of?(self.class) && persisted? && other.id == id
    else
      super
    end
  end
  alias :eql? :==

  # Use ID as base for hash
  def hash
    id.hash
  end

  # Attribute reader with type-casting
  # @return [Object]
  def [](name)
    __ensure_loaded__
    name = name.to_s
    @__attributes__[name] ||= begin
      column = self.class.columns.lookup[name]
      value  = super(name)
      column ? column.type_cast(value) : value
    end
  end

  # Attribute writer
  # @param [String] name
  # @param [Object] value
  def []=(name, value)
    __ensure_loaded__
    name = name.to_s
    @__attributes__.delete(name)
    super
  end

  # Returns a Hash with attributes
  # @param [Boolean] clean
  #   If true, only actual values will be returned (without nils), defaults to false
  # @return [Hash]
  def to_hash(clean = false)
    __ensure_loaded__
    attrs = clean ? reject {|_, v| v.nil? } : self
    {}.update(attrs)
  end

  # Show information about this record
  # @return [String]
  def inspect
    __ensure_loaded__
    "#<#{self.class.name} #{super}>"
  end

  # Bulk-update attributes
  # @param [Hash] attrs
  def update(attrs)
    attrs = (attrs ? attrs.stringify_keys : {})
    attrs["id"] = attrs["id"].to_s if attrs["id"]
    super
  end

  private

    def __ensure_loaded__
      refresh_attributes unless @__loaded__
    end

end
