require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

desc 'Default: run unit tests.'
task :default => :test

desc 'Test the path_finder plugin.'
Rake::TestTask.new(:test) do |t|
  t.libs << 'lib'
  t.libs << 'test'
  t.pattern = 'test/**/*_test.rb'
  t.verbose = true
end

desc 'Generate documentation for the path_finder plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'PathFinder'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

begin
  require 'jeweler'
  Jeweler::Tasks.new do |gemspec|
    gemspec.name = "path_finder"
    gemspec.summary = "Textual path for self-referential models"
    gemspec.description = "Textual path for self-referential models"
    gemspec.email = "kris.leech@interkonect.com"
    gemspec.homepage = "http://github.com/krisleech/Path-Finder"
    gemspec.authors = ["Kris Leech"]
  end
rescue LoadError
  puts "Jeweler not available. Install it with: gem install jeweler"
end

