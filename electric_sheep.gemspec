# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'electric_sheep/version'

Gem::Specification.new do |spec|
  spec.name          = "electric_sheep"
  spec.version       = ElectricSheep::VERSION
  spec.authors       = ["Benoît Anselme", "Patrice Izzo", "Jef Mathiot", "Fabrice Nourisson",
                        "Eric Hartmann"]
  spec.email         = ["foss@servebox.com"]
  spec.description   = %q{A simple task system for file manipulation (i.e. backup).}
  spec.summary       = %q{A simple task system for file manipulation (i.e. backup).}
  spec.homepage      = "https://github.com/servebox/electric_sheep"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency "mocha"
  spec.add_development_dependency "coveralls"
  spec.add_development_dependency "minitest", "~> 5.4.1"
  spec.add_development_dependency "minitest-implicit-subject", "~> 1.4.0"
  spec.add_development_dependency "rb-readline", "~> 0.5.0"
  spec.add_development_dependency "guard-minitest", "~> 2.3.2"
  spec.add_development_dependency "timecop"

  spec.add_dependency "thor", "~> 0.19.1"
  spec.add_dependency "activesupport", ">= 3.0.0"
  spec.add_dependency "session", "~> 3.2.0"
  spec.add_dependency "net-ssh", "~> 2.9.0"
  spec.add_dependency "net-scp", "~> 1.2.1"

end
