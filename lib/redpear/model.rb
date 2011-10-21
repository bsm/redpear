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
  include Redpear::Connection
  include Redpear::Namespace
  include Redpear::Persistence
  include Redpear::Expiration
  include Redpear::Schema
  include Redpear::Finders

  # Ensure we can read raw level values
  alias_method :__fetch__, :[]

  def initialize(attrs = {})
    super()
    @__attributes__ = {}
    @__loaded__     = true
    update(attrs)
  end

  # Every record needs an ID
  def id
    value = __fetch__("id")
    value.to_s if value
  end

  # Custom comparator
  def ==(other)
    case other
    when Redpear::Model
      other.instance_of?(self.class) && to_hash(true) == other.to_hash(true)
    else
      super
    end
  end

  # Attribute reader with type-casting
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
  def []=(name, value)
    __ensure_loaded__
    name = name.to_s
    @__attributes__.delete(name)
    super
  end

  # Returns a Hash with attributes
  def to_hash(clean = false)
    __ensure_loaded__
    attrs = clean ? reject {|_, v| v.nil? } : self
    {}.update(attrs)
  end

  # Show information about this record
  def inspect
    __ensure_loaded__
    "#<#{self.class.name} #{super}>"
  end

  # Bulk-update attributes
  def update(attrs)
    attrs = (attrs ? attrs.stringify_keys : {})
    attrs["id"] = attrs["id"].to_s if attrs["id"]
    super
  end
  alias_method :load, :update

  private

    def __ensure_loaded__
      refresh_attributes unless @__loaded__
    end

end
