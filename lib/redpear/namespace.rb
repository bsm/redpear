# Namespace organization for models. Example:
#
#   class Comment < Model
#     index :post_id
#   end
#   instance = Comment.save(:post_id => 2)
#
#   Comment.connection.keys
#   # => ['comments:1', 'comments:+', 'comments:*', 'comments:post_id:2']
#
#   # Instance nesting
#   instance.nest                  # => 'comments:1'
#   instance.nest.mapped_hmget_all # => { "post_id" => "2" }
#
#   # Member nesting
#   Comment.mb_nest               # "comments:*"
#   Comment.mb_nest.smembers      # => #<Set: {1}>
#
#   # PK nesting
#   Comment.pk_nest               # "comments:+"
#   Comment.pk_nest.get           # 1 = last ID
#
#   # Index nesting
#   Comment.columns["post_id"].nest(2) # "comments:post_id:2"
#   Comment.columns["post_id"].nest(2).smembers # #<Set: {1}>
#
module Redpear::Namespace
  extend Redpear::Concern

  module ClassMethods

    def namespace
      @namespace ||= Redpear::Nest.new(scope, connection)
    end

    def scope
      @scope ||= "#{name.split('::').last.downcase}s"
    end

    # Store for all member IDs. Example:
    #
    #   Model.mb_nest # => 'models:*'
    #   Model.mb_nest.smembers # => [1, 2, 3]
    def mb_nest
      @mb_nest ||= namespace["*"]
    end

    # Incrementor for member primary keys. Example:
    #
    #   Model.pk_nest # => 'models:+'
    #   Model.pk_nest.get # => 0
    #   Model.pk_nest.incr # => 1
    def pk_nest
      @pk_nest ||= namespace["+"]
    end

  end

  def nest
    self.class.namespace[id || '_']
  end

end
