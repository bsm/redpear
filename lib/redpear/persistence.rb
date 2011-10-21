# Redpear's persistence methods
module Redpear::Persistence
  extend Redpear::Concern

  module ClassMethods

    # Runs a bulk-operation.
    # @yield [] operations that should be run in the transaction
    def transaction(&block)
      connection.multi(&block)
    end

    # Create or update a record. Example:
    #
    #   Post.save :body => "Hello World!" # => creates a new Post
    #   Post.save :id => 3, :body => "Hello World!" # => updates an existing Post
    #
    def save(*args)
      new(*args).tap(&:save)
    end

    # Destroys a record. Example:
    # @param id the ID of the record to destroy
    # @return [Redpear::Model] the destroyed record
    def destroy(id)
      new('id' => id).tap(&:destroy)
    end

    # Generates the next ID
    def next_id
      pk_nest.incr.to_s
    end

  end

  # Returns true for new records
  def new_record?
    !id
  end

  # Returns true for existing records
  def persisted?
    !new_record?
  end

  # Reloads the record (destructive)
  def reload
    replace self.class.find(id, :lazy => false) if persisted?
    self
  end

  # Load attributes from DB (destructive)
  def refresh_attributes
    update nest.mapped_hmget(*self.class.columns.names) if persisted?
    @__loaded__ = true
    self
  end

  # Saves the record.
  #
  # @param [Hash] options additional options
  # @option options [Integer|Date] :expire expiration period or timestamp
  # @yield [record] Additional block, applied as part of the save transaction
  # @return [Redpear::Model] the saved record
  def save(options = {}, &block)
    before_save
    update "id" => self.class.next_id unless persisted?

    transaction do
      nest.mapped_hmset __persistable_attributes__
      __relevant_sets__.each {|s| s.sadd(id) }
      expire options[:expire]
      yield(self) if block
    end
  ensure
    after_save
  end

  # Destroy the record.
  # @return [Boolean] true or false
  def destroy
    return false unless persisted?

    transaction do
      nest.del
      __relevant_sets__.each {|s| s.srem(id) }
    end

    true
  end

  protected

    # Run in a DB transaction, returns self
    def transaction(&block)
      self.class.transaction(&block)
      self
    end

    # "Cheap" callback, override in subclasses
    def before_save
    end

    # "Cheap" callback, override in subclasses
    def after_save
    end

  private

    # Attributes that can be persisted
    def __persistable_attributes__
      result = {}
      each do |key, value|
        next if key == "id"
        result[key] = __persistable_value__(value)
      end
      result
    end

    def __persistable_value__(value)
      case value
      when Time
        value.to_i
      else
        value
      end
    end

    # Return relevant set nests
    def __relevant_sets__
      @__relevant_sets__ ||= [self.class.mb_nest] + self.class.columns.indices.map {|i| i.nest self[i] }.compact
    end

end
