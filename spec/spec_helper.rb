require 'simplecov'
require 'coveralls'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]

SimpleCov.start do
  add_filter '/spec/'
end

require 'electric_sheep'
require 'minitest'
require 'minitest/spec'
require 'minitest/autorun'
require 'minitest/pride'
require 'minitest-implicit-subject'
require 'mocha/setup'

require 'support/hosts'
require 'support/shell_metadata'
require 'support/options'
require 'support/queue'

ENV['ELECTRIC_SHEEPS_HOME'] = Dir.mktmpdir
