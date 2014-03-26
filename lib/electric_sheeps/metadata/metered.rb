module ElectricSheeps
  module Metadata
    module Metered
      extend ActiveSupport::Concern

      included do
        attr_reader :execution_time
      end

      def benchmarked
        start = Time.now
        yield if block_given?
        @execution_time = (Time.now - start) / 1000
        self
      end
    end
  end
end
