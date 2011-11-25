module Redpear::Finders
  extend Redpear::Concern

  module ClassMethods

    # @return [Array] the IDs of all existing records
    def members
      Redpear::Members.new(mb_nest)
    end

    # @return [Integer] the number of total records
    def count
      members.count
    end

    # @return [Array] all records
    def all
      members.map {|id| find(id) }
    end

    # Finds a single record.
    #
    # @param id the ID of the record to retrieve
    # @param [Hash] options additional options
    # @option :lazy defaults to true, set to false to load the record instantly
    # @return [Redpear::Model] a record, or nil when not found
    def find(id, options = {})
      record = instantiate('id' => id.to_s) # Initialize
      if record.nest.exists         # Do we have a record key?
        record.refresh_attributes if options[:lazy] == false
        record
      else                          # Must be an expired or orphaned one
        record.destroy              # Destroy (removes from mb_nest set)
        nil
      end
    end

    # @param id the ID to check
    # @return [Boolean] true or false
    def exists?(id)
      members.exists?(id)
    end

    def instantiate(*a)
      new(*a).tap do |instance|
        instance.send :instance_variable_set, :@__loaded__, false
      end
    end

  end
end
