module ElectricSheep
  module Helpers
    module Timestamps
      def timestamp
        Time.now.utc.strftime('%Y%m%d-%H%M%S')
      end
    end
  end
end
