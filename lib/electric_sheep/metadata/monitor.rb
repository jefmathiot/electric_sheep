module ElectricSheep
  module Metadata
    module Monitor
      extend ActiveSupport::Concern

      included do
        attr_reader :execution_time, :status
      end

      def monitored
        start = Time.now
        output = yield if block_given?
        @status = :success
        output
      rescue Exception => e
        @status = :failed
        raise e
      ensure
        @execution_time = (Time.now - start)
      end

      def successful?
        status == :success
      end

      def failed?
        status == :failed
      end
    end
  end
end
