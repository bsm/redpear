module Redpear::Model::Finders
  extend Redpear::Concern

  module ClassMethods

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

  end
end