require 'rake'
require 'bundler/gem_tasks'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)

require 'yard'
require 'yard/rake/yardoc_task'
YARD::Rake::YardocTask.new

require 'coveralls/rake/task'
Coveralls::RakeTask.new
namespace :spec do
  task coveralls: [:spec, 'coveralls:push']
end

desc 'Default: run specs.'
task default: :spec
