# -*- encoding: utf-8 -*-
require File.expand_path('../lib/redpear/version', __FILE__)

Gem::Specification.new do |s|
  s.platform = Gem::Platform::RUBY
  s.required_ruby_version = '>= 1.9.2'
  s.required_rubygems_version = ">= 1.3.6"

  s.name        = "redpear"
  s.summary     = "Redpear, a Redis ORM"
  s.description = "Simple, elegant & efficient ORM for Redis"
  s.version     = Redpear::VERSION::STRING.dup

  s.authors     = ["Dimitrij Denissenko"]
  s.email       = "dimitrij@blacksquaremedia.com"
  s.homepage    = "https://github.com/bsm/redpear"

  s.require_path = 'lib'
  s.files        = Dir['lib/**/*']

  s.add_dependency "redis", "~> 2.2.0"
  s.add_development_dependency "rake"
  s.add_development_dependency "bundler"
  s.add_development_dependency "rspec"
  s.add_development_dependency "shoulda-matchers"
  s.add_development_dependency "machinist"
  s.add_development_dependency "factory_girl"
  s.add_development_dependency "hiredis"
end
