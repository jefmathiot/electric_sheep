require 'simplecov'
require 'coveralls'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]

SimpleCov.start

require 'electric_sheeps'
require 'minitest'
require 'minitest/spec'
require 'minitest/autorun'
require 'minitest/pride'
require 'mocha/setup'
