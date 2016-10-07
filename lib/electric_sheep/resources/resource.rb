module ElectricSheep
  module Resources
    class Resource < Metadata::Base
      include Metadata::Typed

      attr_reader :timestamp, :transient
      alias timestamp? timestamp
      alias transient? transient

      def timestamp!(origin)
        @timestamp = if origin.timestamp?
                       origin.timestamp
                     else
                       Time.now.utc.strftime('%Y%m%d-%H%M%S')
                     end
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
        host.blank? || host.local?
      end

      def transient!
        @transient = true
        self
      end
    end
  end
end
