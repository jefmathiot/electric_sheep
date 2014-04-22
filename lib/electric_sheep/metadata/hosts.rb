module ElectricSheep
  module Metadata

    class Host < Base
      option :id, required: true
      option :hostname, required: true
      option :description
      # TODO Validate hostname is valid
      
      def local?
        false
      end
    end

    class Localhost < Base
      def local?
        true
      end
    end

    class Hosts

      def localhost
        @localhost ||= Localhost.new
      end
      
      def add(id, options)
        hosts[id] = Host.new(options.merge(id: id))
      end

      def get(id)
        hosts[id]
      end

      private
      def hosts
        @hosts ||= {}
      end

    end

  end
end
