# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require File.expand_path('../lib/netdnarws/version', __FILE__)

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

Gem::Specification.new do |gem|
  gem.name = "netdnarws"
  gem.homepage = "http://developer.netdna.com"
  gem.version = File.exist?('VERSION') ? File.read('VERSION') : ""
  gem.license = "MIT"
  gem.files = `git ls-files`.split('\n')
  gem.require_paths = ['lib']
  gem.summary = %Q{A Rest Client For NetDNA Rest Web Services}
  gem.description = %Q{A Rest Client For NetDNA Rest Web Services}
  gem.email = "devteam@netdna.com"
  gem.authors = ["NetDNA Developer Team"]
  gem.add_runtime_dependency 'oauth'
end

require 'rdoc/task'
Rake::RDocTask.new do |rdoc|
  version = File.exist?('VERSION') ? File.read('VERSION') : ""

  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "netdnarws #{version}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end
