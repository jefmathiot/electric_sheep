module ElectricSheep
  module Metadata
    class Base
      include Options

      def initialize(opts={})
        @options = opts
      end

    end

  end
end
