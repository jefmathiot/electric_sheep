# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'electric_sheep/version'

Gem::Specification.new do |spec|
  spec.name          = "electric_sheep"
  spec.version       = ElectricSheep::VERSION
  spec.authors       = ["Benoit Anselme", "Patrice Izzo", "Jef Mathiot", "Fabrice Nourisson",
                        "Eric Hartmann", "Benjamin Severac"]
  spec.email         = ["foss@servebox.com"]
  spec.description   = %q{A backup system for Application Developers.}
  spec.summary       = %q{A backup system for Application Developers and DevOps.}
  spec.homepage      = "https://github.com/servebox/electric_sheep"
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.files.reject! { |fn| fn =~ /^acceptance\// || fn =~ /^build\// }
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency 'bundler', '>= 1.3.0', '< 2.0'
  spec.add_development_dependency 'rake', '~>10.3', '>= 10.3.2'
  spec.add_development_dependency 'mocha', '~> 1.1', '>= 1.1.0'
  spec.add_development_dependency 'coveralls', '~> 0.7', '>= 0.7.1'
  spec.add_development_dependency 'minitest', '~> 5.4', '>= 5.4.1'
  spec.add_development_dependency 'minitest-implicit-subject', '~> 1.4', '>= 1.4.0'
  spec.add_development_dependency 'rb-readline', '~> 0.5', '>= 0.5.0'
  spec.add_development_dependency 'guard', '~> 2.11', '>= 2.11.1'
  spec.add_development_dependency 'guard-minitest', '~> 2.3', '>= 2.3.2'
  spec.add_development_dependency 'timecop', '~> 0.7', '>= 0.7.1'
  spec.add_development_dependency 'aruba', '~> 0.6', '>= 0.6.1'

  spec.add_dependency 'thor', '~> 0.19', '>= 0.19.1'
  spec.add_dependency 'colorize', '~> 0.7', '>= 0.7.3'
  spec.add_dependency 'activesupport', '~> 4.1', '>= 4.1.0'
  spec.add_dependency 'session', '~> 3.2', '>= 3.2.0'
  spec.add_dependency 'net-ssh', '~> 2.9', '>= 2.9.0'
  spec.add_dependency 'net-scp', '~> 1.2', '>= 1.2.1'
  spec.add_dependency 'fog', '~> 1.23', '>= 1.23.0'
  spec.add_dependency 'lumberjack', '~> 1.0', '>= 1.0.9'
  spec.add_dependency 'mail', '~> 2.6', '>= 2.6.3'
  spec.add_dependency 'premailer', '~> 1.8', '>= 1.8.2'
  spec.add_dependency 'posix-spawn', '~> 0.3', '>= 0.3.9'
  spec.add_dependency 'git_rev', '~> 0.1', '>= 0.1.0'

end
