require 'redpear/model/factory_bot'

FactoryBot.define do

  factory :post do
    title      { "A Title" }
    created_at { Time.at(1313131313) }
  end

end
