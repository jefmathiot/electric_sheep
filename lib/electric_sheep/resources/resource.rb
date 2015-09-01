module ElectricSheep
  module Resources
    class Resource < Metadata::Base
      include Metadata::Typed

      attr_reader :timestamp, :transient

      def timestamp!(origin)
        @timestamp = origin.timestamp || Time.now.utc.strftime('%Y%m%d-%H%M%S')
      end

      def stat!(size)
        @stat = Stat.new(size)
        self
      end

      def stat
        @stat ||= Stat.new
      end

      def remote?
        !local?
      end

      def local?
        host.nil? || host.local?
      end

      def transient!
        @transient = true
        self
      end
    end
  end
end
