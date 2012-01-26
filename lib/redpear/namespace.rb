# Namespace organization for models. Example:
#
#   class Comment < Model
#     index :post_id
#   end
#   instance = Comment.save(:post_id => 2)
#
#   Comment.namespace.keys
#   # => ['comments:1', 'comments:+', 'comments:*', 'comments:post_id:2']
#
#   # Instance nesting
#   instance.nest                 # => 'comments:1'
#   instance.nest.hgetall         # => { "post_id" => "2" }
#
#   # Index nesting
#   Comment.columns["post_id"].nest(2) # "comments:post_id:2"
#   Comment.columns["post_id"].nest(2).smembers # #<Set: {1}>
#
module Redpear::Namespace
  extend Redpear::Concern

  module ClassMethods

    # @return [Redpear::Nest] the namespace of this model, Example:
    #
    #   Comment.namespace # => "comments":Redpear::Nest
    #
    def namespace
      @namespace ||= Redpear::Nest.new(scope, connection)
    end

    # @return [String] the scope of this model. Example:
    #
    #   Comment.scope # => "comments"
    #
    # Override if you want to use a differnet scope schema.
    def scope
      @scope ||= "#{name.split('::').last.downcase}s"
    end

  end

  # @return [Redpear::Nest] the nest for the current record. Example:
  #
  #   comment.nest # => 'comments:123'
  #   Comment.new.nest # => 'comments:_'
  #
  def nest
    self.class.namespace[id || '_']
  end

end
