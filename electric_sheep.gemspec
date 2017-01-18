# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'electric_sheep/version'

Gem::Specification.new do |spec|
  spec.name          = "electric_sheep"
  spec.version       = ElectricSheep::VERSION
  spec.authors       = [
                        "Benoit Anselme",
                        "Sylvain Didier",
                        "Patrice Izzo",
                        "Jef Mathiot",
                        "Fabrice Nourisson",
                        "Eric Hartmann",
                        "Benjamin Severac",
                        "Christophe Vilayphiou"
                       ]
  spec.email         = ["humans@electricsheep.io"]
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
  spec.add_development_dependency 'rake', '~> 10.4', '>= 10.4.2'
  spec.add_development_dependency 'mocha', '~> 1.1', '>= 1.1.0'
  spec.add_development_dependency 'coveralls', '~> 0.8', '>= 0.8.9'
  spec.add_development_dependency 'minitest', '~> 5.8', '>= 5.8.3'
  spec.add_development_dependency 'minitest-implicit-subject', '~> 1.4', '>= 1.4.0'
  spec.add_development_dependency 'rb-readline', '~> 0.5', '>= 0.5.3'
  spec.add_development_dependency 'guard', '~> 2.13', '>= 2.13.0'
  spec.add_development_dependency 'guard-minitest', '~> 2.4', '>= 2.4.4'
  spec.add_development_dependency 'timecop', '~> 0.8', '>= 0.8.0'
  spec.add_development_dependency 'aruba', '~> 0.10', '>= 0.10.2'
  spec.add_development_dependency 'rubocop', '~> 0.35', '>= 0.35.1'

  spec.add_dependency 'thor', '~> 0.19', '>= 0.19.1'
  spec.add_dependency 'colorize', '~> 0.7', '>= 0.7.7'
  spec.add_dependency 'activesupport', '~> 5.0', '>= 5.0.1'
  spec.add_dependency 'session', '~> 3.2', '>= 3.2.0'
  spec.add_dependency 'net-ssh', '~> 3.0', '>= 3.0.1'
  spec.add_dependency 'net-scp', '~> 1.2', '>= 1.2.1'
  spec.add_dependency 'fog', '~> 1.36', '>= 1.36.0'
  spec.add_dependency 'lumberjack', '~> 1.0', '>= 1.0.9'
  spec.add_dependency 'mail', '~> 2.6', '>= 2.6.3'
  spec.add_dependency 'premailer', '~> 1.8', '>= 1.8.6'
  spec.add_dependency 'posix-spawn', '~> 0.3', '>= 0.3.11'
  spec.add_dependency 'git_rev', '~> 0.1', '>= 0.1.0'
  spec.add_dependency 'parse-cron', '~> 0.1', '>= 0.1.4'
  spec.add_dependency 'table_print', '~> 1.5', '>= 1.5.4'

end
