module ElectricSheep
  module Metadata
    class Configured < Base
      attr_reader :config

      def initialize(config, opts = {})
        @config = config
        super(opts)
      end
    end
  end
end
