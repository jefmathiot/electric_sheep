module ElectricSheep
  module Metadata
    class Base
      include Properties

      def initialize(options={})
        @options = options
      end

    end

  end
end
