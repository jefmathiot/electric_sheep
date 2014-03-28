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
        @resources = options[:resources]
      end

      def method_missing(method, *args, &block)
        if @resources.has_key?(method)
          @resources[method]
        else
          super
        end
      end
    end
  end
end
