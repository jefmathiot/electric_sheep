require 'colorize'
require 'lumberjack'

module Lumberjack
  class Template
    alias_method :boring_call, :call

    COLORS=[
      :white,
      :green,
      :orange,
      :red,
      :red,
      :white
    ].freeze

    define_method :call do |entry|
      boring_call(entry).send(COLORS[entry.severity])
    end
  end
end