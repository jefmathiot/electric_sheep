module ElectricSheeps
  module Agents
    module Command
      extend ActiveSupport::Concern
      include Agent

      attr_reader :logger, :shell, :work_dir

      def initialize(options={})
        @logger = options[:logger]
        @shell = options[:shell]
        @work_dir = options[:work_dir]
      end

    end
  end
end
