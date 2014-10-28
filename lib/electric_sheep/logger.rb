require 'colorize'
require 'lumberjack'

module Lumberjack
  class Template
    alias_method :boring_call, :call

    COLORS=[
      :cyan,
      :green,
      :yellow,
      :red,
      :red,
      :white
    ].freeze

    define_method :call do |entry|
      boring_call(entry).send(COLORS[entry.severity])
    end
  end
end