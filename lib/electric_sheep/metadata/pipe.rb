module ElectricSheep
  module Metadata
    module Pipe
      include Queue
      include Monitor

      attr_reader :input, :start_location

      def pipelined(resource, &block)
        init(resource)
        monitored do
          iterate do |item|
            done!( item, yield(item, last_product), item.execution_time )
          end
        end
      end

      def last_product
        execs.size > 0 && execs.last.product || input
      end

      def execs
        @execs ||= []
      end

      protected

      def done!(metadata, product, execution_time)
        execs << ExecTrail.new(metadata, product, execution_time)
      end

      def init(resource)
        @input=resource
        @start_location=resource.to_location
      end

      ExecTrail=Struct.new(:metadata, :product, :execution_time)

      Location=Struct.new(:id, :location, :type)

    end

  end
end
