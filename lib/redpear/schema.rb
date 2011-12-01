module Redpear::Schema
  extend Redpear::Concern
  autoload :Collection, 'redpear/schema/collection'

  module ClassMethods

    # @return [Redpear::Schema::Collection] the columns of this model
    def columns
      @columns ||= Redpear::Schema::Collection.new
    end

    # @param [multiple] the column definition. Please see Redpear::Column#initialize
    def column(*args)
      columns.store(Redpear::Column, self, *args).tap do |col|
        __define_attribute_accessors__(col)
      end
    end

    # @param [multiple] the index definition. Please see Redpear::Column#initialize
    def index(*args)
      columns.store(Redpear::Index, self, *args).tap do |col|
        __define_attribute_accessors__(col)
      end
    end

    # @param [multiple] the sorted index definition. Please see Redpear::Column#initialize
    def zindex(*args)
      columns.store(Redpear::ZIndex, self, *args).tap do |col|
        __define_attribute_accessors__(col)
      end
    end

    private

      def __define_attribute_accessors__(col)
        define_method(col.name) { self[col.name] } if col.readable?
        define_method("#{col.name}=") {|v| self[col.name] = v } if col.writable?
      end

  end
end
