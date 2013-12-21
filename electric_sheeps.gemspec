# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'electric_sheeps/version'

Gem::Specification.new do |spec|
  spec.name          = "electric_sheeps"
  spec.version       = ElectricSheeps::VERSION
  spec.authors       = ["Benoît Anselme", "Patrice Izzo", "Jef Mathiot", "Fabrice Nourisson"]
  spec.email         = ["foss@servebox.com"]
  spec.description   = %q{A simple task system for file manipulation (i.e. backup).}
  spec.summary       = %q{A simple task system for file manipulation (i.e. backup).}
  spec.homepage      = "https://github.com/servebox/electric_sheeps"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "mocha"
  spec.add_development_dependency "coveralls"
  spec.add_development_dependency "minitest", "~> 5.0.7"
  #spec.add_development_dependency "mock_redis", "~> 0.10.0"
  spec.add_development_dependency 'guard-minitest'

  #spec.add_dependency "redis-namespace", ">= 1.3.0"
  spec.add_dependency "session", "~> 3.1.0"
  spec.add_dependency "net-ssh", "~> 2.7.0"
end
