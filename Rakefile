# encoding: utf-8

require 'rubygems'
require 'bundler'
begin
  Bundler.setup(:default, :development)
rescue Bundler::BundlerError => e
  $stderr.puts e.message
  $stderr.puts "Run `bundle install` to install missing gems"
  exit e.status_code
end
require 'rake'

require 'jeweler'
Jeweler::Tasks.new do |gem|
  gem.name = "netdnarws"
  gem.homepage = "http://developer.netdna.com"
  gem.license = "MIT"
  gem.summary = %Q{A Rest Client For NetDNA Rest Web Services}
  gem.description = %Q{A Rest Client For NetDNA Rest Web Services}
  gem.email = "devteam@netdna.com"
  gem.authors = ["NetDNA Developer Team"]
  gem.add_dependency 'oauth'
end
Jeweler::RubygemsDotOrgTasks.new

require 'rake/rdoctask'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "netdnarws #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
