require 'factory_girl'
require 'redpear/model'

class Redpear::Model

  # FactoryGirl module for your tests/specs. Example:
  #
  #   require 'redpear/model/factory_girl'
  #
  #   FactoryGirl.define do
  #     factory :post do
  #       title      { "A Title" }
  #       created_at { Time.at(1313131313) }
  #     end
  #   end
  #
  module FactoryGirl

    # @return [Boolean] always true. FactoryGirl requires it.
    def save!
      true
    end

  end
  include FactoryGirl

end
