require "bundler/gem_tasks"

require 'rake/testtask'
require 'rubocop/rake_task'

Rake::TestTask.new do |t|
  t.libs << 'spec'
  t.pattern = "spec/**/*_spec.rb"
end

RuboCop::RakeTask.new do |task|
  task.patterns = ['lib/**/*.rb', 'spec/**/*.rb']
end

task :default => [:test, :rubocop]
