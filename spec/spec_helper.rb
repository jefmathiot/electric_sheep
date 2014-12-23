require 'simplecov'
require 'coveralls'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]

SimpleCov.start do
  add_filter '/spec/'
end

ENV['ELECTRIC_SHEEP_ENV']='test'

require 'electric_sheep'
require 'minitest'
require 'minitest/spec'
require 'minitest/autorun'
require 'minitest/pride'
require 'minitest-implicit-subject'
require 'mocha/setup'

require 'support/hosts'
require 'support/hosted'
require 'support/shell_metadata'
require 'support/options'
require 'support/command'
require 'support/queue'
require 'support/transport'
require 'support/files'

ENV['ELECTRIC_SHEEPS_HOME'] = Dir.mktmpdir
