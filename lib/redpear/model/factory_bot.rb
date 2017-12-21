require 'factory_bot'
require 'redpear/model'

class Redpear::Model

  # FactoryBot module for your tests/specs. Example:
  #
  #   require 'redpear/model/factory_bot'
  #
  #   FactoryBot.define do
  #     factory :post do
  #       title      { "A Title" }
  #       created_at { Time.at(1313131313) }
  #     end
  #   end
  #
  module FactoryBot

    # @return [Boolean] always true. FactoryBot requires it.
    def save!
      after_save({}) # call after_save again
      true
    end

  end
  include FactoryBot

end
