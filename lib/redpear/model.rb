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

  post = Post.create :title => "Hi!", :body => "I'm a new post"
  comment = Comment.create :post_id => post.id, :body => "I like this!"

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
  alias_method :_fetch, :[]

  def initialize(attrs = {})
    super()
    @_attribute_cache = {}
    update(attrs)
  end

  # Every record needs an ID
  def id
    value = _fetch("id")
    value.to_s if value
  end

  # Bulk-update attributes
  def update(attrs)
    super attrs.stringify_keys
  end
  alias_method :load, :update

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
    name = name.to_s
    @_attribute_cache[name] ||= begin
      column = self.class.columns.lookup[name]
      value  = super(name)
      column ? column.type_cast(value) : value
    end
  end

  # Attribute writer
  def []=(name, value)
    name = name.to_s
    @_attribute_cache.delete(name)
    super
  end

  # Returns a Hash with attributes
  def to_hash(clean = false)
    attrs = clean ? reject {|_, v| v.nil? } : self
    {}.update(attrs)
  end

  # Show information about this record
  def inspect
    "#<#{self.class.name} #{super}>"
  end

end
