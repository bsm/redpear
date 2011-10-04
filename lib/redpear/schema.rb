module Redpear::Schema
  extend Redpear::Concern
  autoload :Collection, 'redpear/schema/collection'

  module ClassMethods

    def columns
      @columns ||= Redpear::Schema::Collection.new
    end

    def column(*args)
      columns.column(self, *args).tap do |col|
        define_attribute_accessors(col)
      end
    end

    def index(*args)
      columns.index(self, *args).tap do |col|
        define_attribute_accessors(col)
      end
    end

    private

      def define_attribute_accessors(col)
        define_method(col.name) { self[col.name] } if col.readable?
        define_method("#{col.name}=") {|v| self[col.name] = v } if col.writable?
      end

  end
end
