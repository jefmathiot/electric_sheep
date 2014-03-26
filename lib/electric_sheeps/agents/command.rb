module ElectricSheeps
  module Agents
    module Command

      attr_reader :logger, :shell

      def initialize(options)
        @logger = options[:logger]
        @shell = options[:shell]
      end

    end
  end
end
