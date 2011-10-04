module Redpear::Persistence
  extend Redpear::Concern

  module ClassMethods

    def transaction(&block)
      connection.multi(&block)
    end

    def save(*args)
      new(*args).tap(&:save)
    end

    def destroy(id)
      new('id' => id).tap(&:destroy)
    end

    # Generate the next ID
    def next_id
      pk_nest.incr.to_s
    end

  end

  def new_record?
    !id
  end

  def persisted?
    !new_record?
  end

  # Reload the record (destructive)
  def reload
    replace self.class.find(id) if persisted?
    self
  end

  # Save the record
  def save(options = {}, &block)
    before_save
    update "id" => self.class.next_id unless persisted?

    transaction do
      nest.mapped_hmset persistable_attributes
      relevant_sets.each {|s| s.sadd(id) }
      expire options[:expire]
      instance_eval(&block) if block
    end
  ensure
    after_save
  end

  # Destroy the record
  def destroy
    return false unless persisted?

    transaction do
      nest.del
      relevant_sets.each {|s| s.srem(id) }
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

    # Attributes that can be persisted
    def persistable_attributes
      result = {}
      each do |key, value|
        next if key == "id"
        result[key] = persistable_value(value)
      end
      result
    end

    def persistable_value(value)
      case value
      when Time
        value.to_i
      else
        value
      end
    end

    # Return relevant set nests
    def relevant_sets
      @relevant_sets ||= [self.class.mb_nest] + self.class.columns.indices.map {|i| i.nest self[i] }.compact
    end

end
