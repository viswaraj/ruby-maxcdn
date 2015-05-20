# -*- encoding: utf-8 -*-
require File.expand_path('../lib/maxcdn/version', __FILE__)

Gem::Specification.new do |gem|
  gem.name = "maxcdn"
  gem.homepage = "http://www.maxcdn.com"
  gem.version = MaxCDN::VERSION
  gem.license = "MIT"
  gem.files = `git ls-files`.split($\)
  gem.require_paths = ['lib']
  gem.summary = %Q{A Rest Client For MaxCDN Rest Web Services}
  gem.description = %Q{A Rest Client For MaxCDN Rest Web Services}
  gem.email = "joshua@mervine.net"
  gem.authors = ["Joshua P. Mervine"]
  gem.add_dependency 'json' if RUBY_VERSION.start_with? "1.8"
  gem.add_dependency 'signet', '~> 0.5.1'
  gem.add_dependency 'curb-fu', '~> 0.6.2'
end
