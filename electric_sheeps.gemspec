# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'electric_sheeps/version'

Gem::Specification.new do |spec|
  spec.name          = "electric_sheeps"
  spec.version       = ElectricSheeps::VERSION
  spec.authors       = ["Benoît Anselme", "Patrice Izzo", "Jef Mathiot", "Fabrice Nourisson"]
  spec.email         = ["info@servebox.com"]
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
end
