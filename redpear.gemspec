# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>= 1.8.7'
  s.required_rubygems_version = ">= 1.6.0"

  s.name        = "redpear"
  s.summary     = "Redpear, a Redis ORM"
  s.description = "Simple, elegant & efficient ORM for Redis"
  s.version     = "0.3.5"

  s.authors     = ["Dimitrij Denissenko"]
  s.email       = "dimitrij@blacksquaremedia.com"
  s.homepage    = "https://github.com/bsm/redpear"

  s.require_path = 'lib'
  s.files        = Dir['lib/**/*']

  s.add_dependency "redis", "~> 2.2.0"
  s.add_dependency "nest", "~> 1.1.0"

  s.add_development_dependency "rake"
  s.add_development_dependency "bundler"
  s.add_development_dependency "rspec"
  s.add_development_dependency "fakeredis"
  s.add_development_dependency "shoulda-matchers"
end
