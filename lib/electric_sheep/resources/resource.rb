module ElectricSheep
  module Resources
    class Resource < Metadata::Base
      include Metadata::Typed

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

      def stat!(size)
        @stat=Stat.new(size)
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
        @transient=true
        self
      end

      def transient?
        !!@transient
      end

    end
  end
end
