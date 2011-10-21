module Redpear::Finders
  extend Redpear::Concern

  module ClassMethods

    # @return [Array] the IDs of all existing records
    def members
      mb_nest.smembers
    end

    # @return [Integer] the number of total records
    def count
      members.size
    end

    # @return [Array] all records
    def all
      members.map {|id| find(id) }
    end

    # Finds a single record.
    #
    # @param id the ID of the record to retrieve
    # @return [Redpear::Model] a record, or nil when not found
    def find(id)
      return nil unless exists?(id) # Skip if ID is not a member of mb_nest
      record = new('id' => id.to_s) # Initialize

      if record.nest.exists         # Do we have a record key?
        pairs = record.nest.mapped_hmget *columns.names
        record.update pairs
      else                          # Must be an expired or orphaned one
        record.destroy              # Destroy (removes from mb_nest set)
        nil
      end
    end

    # @param id the ID to check
    # @return [Boolean] true or false
    def exists?(id)
      mb_nest.sismember(id)
    end

  end
end
