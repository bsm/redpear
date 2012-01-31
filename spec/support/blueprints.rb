require 'redpear/model/machinist'

Post.blueprint do
  title      { "A Title" }
  created_at { Time.at(1313131313) }
end
