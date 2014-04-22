module ElectricSheep
  module Metadata

    class Host < Base
      option :id, required: true
      option :hostname, required: true
      option :description
      # TODO Validate hostname is valid
    end

    class Hosts
      
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
