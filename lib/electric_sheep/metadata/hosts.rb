module ElectricSheep
  module Metadata

    class Host < Base
      option :id, required: true
      # TODO Validate hostname is valid
      option :hostname, required: true
      option :ssh_port
      option :description
      option :working_directory

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
      attr_accessor :working_directory

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
        return localhost if id=='localhost'
        hosts[id]
      end

      private
      def hosts
        @hosts ||= {}
      end

    end

  end
end
