module Redpear::Schema
  autoload :Collection, 'redpear/schema/collection'
  autoload :Column, 'redpear/schema/column'
  autoload :Index, 'redpear/schema/index'
  autoload :Score, 'redpear/schema/score'
  extend Redpear::Concern

  module ClassMethods

    # @return [Redpear::Schema::Collection] the columns of this model
    def columns
      @columns ||= Redpear::Schema::Collection.new
    end

    # @param [multiple] the column definition. Please see Redpear::Schema::Column#initialize
    def column(*args)
      columns.store(Redpear::Schema::Column, self, *args).tap do |col|
        __define_attribute_accessors__(col)
      end
    end

    # @param [multiple] the index definition. Please see Redpear::Index#initialize
    def index(*args)
      columns.store(Redpear::Schema::Index, self, *args).tap do |col|
        __define_attribute_accessors__(col)
      end
    end

    # @param [multiple] the sorted index definition. Please see Redpear::ZIndex#initialize
    def score(*args)
      columns.store(Redpear::Schema::Score, self, *args).tap do |col|
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
