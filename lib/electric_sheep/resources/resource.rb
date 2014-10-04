module ElectricSheep
  module Resources
    class Resource < Metadata::Base

      option :host, required: true

      attr_reader :timestamp

      def timestamp?
        !!@timestamp
      end

      def timestamp!(origin)
        if origin.timestamp?
          @timestamp=origin.timestamp
        else
          @timestamp=Time.now.utc.strftime('%Y%m%d-%H%M%S')
        end
      end
    end
  end
end
