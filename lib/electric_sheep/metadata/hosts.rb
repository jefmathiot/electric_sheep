module ElectricSheep
  module Metadata

    class Host < Base
      option :id, required: true
      option :hostname, required: true
      option :ssh_port
      option :description
      # TODO Validate hostname is valid

      def initialize(options={})
        options[:ssh_port] ||= 22
        super
      end

      def local?
        false
      end

      def to_s
        id
      end
    end

    class Localhost < Base
      def local?
        true
      end

      def to_s
        "localhost"
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
        hosts[id] || localhost
      end

      private
      def hosts
        @hosts ||= {}
      end

    end

  end
end
