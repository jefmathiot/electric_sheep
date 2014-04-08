module ElectricSheeps
  module Metadata

    class Hosts
      def initialize
        @host = Struct.new(:id, :hostname, :description)
      end

      def add(id, options)
        # TODO Validate options[:name] is a valid hostname
        host = @host.new(id, options[:hostname], options[:description])
        hosts[host.id] = host
      end

      def get(id)
        raise "Unknown host with id #{id}" unless hosts.has_key?(id)
        hosts[id]
      end

      private
      def hosts
        @hosts ||= {}
      end

    end

  end
end
