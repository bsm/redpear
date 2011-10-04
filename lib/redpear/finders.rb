module Redpear::Finders
  extend Redpear::Concern

  module ClassMethods

    # Returns all IDs of exiting records
    def members
      mb_nest.smembers
    end

    # Returns the number of total records
    def count
      members.size
    end

    # Returns all records
    def all
      members.map {|id| find(id) }
    end

    # Find one record
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

    def exists?(id)
      mb_nest.sismember(id)
    end

  end
end
