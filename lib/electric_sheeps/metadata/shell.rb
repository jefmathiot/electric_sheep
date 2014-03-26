module ElectricSheeps
  module Metadata
    class Shell
      include Queue
      include Metered

      def initialize
        reset!
      end
    end
  end
end
