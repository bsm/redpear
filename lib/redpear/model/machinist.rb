require 'machinist'
require 'redpear/model'

# Machinist module for your tests/specs. Example:
#
#   # spec/support/blueprints.rb
#   require "redpear/model/machinist"
#
#   Post.blueprint do
#     title      { "A Title" }
#     created_at { 2.days.ago }
#   end
#
module Redpear::Model::Machinist

  class Blueprint < Machinist::Blueprint

    def make!(attributes = {})
      make(attributes)
    end

    def lathe_class #:nodoc:
      Lathe
    end

  end

  class Lathe < Machinist::Lathe
    protected

    def make_one_value(attribute, args)
      return unless block_given?
      raise_argument_error(attribute) unless args.empty?
      yield
    end

    def assign_attribute(key, value) #:nodoc:
      @assigned_attributes[key.to_sym] = value
      @object.load key => value
    end

  end
end

class Redpear::Model #:nodoc:
  extend ::Machinist::Machinable

  def self.blueprint_class
    self::Machinist::Blueprint
  end
end
