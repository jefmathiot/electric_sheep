module ElectricSheep
  module Metadata

    class BaseHost < Base
      option :working_directory

      def working_directory
        option(:working_directory) || '$HOME/.electric_sheep'
      end
    end

    class Host < BaseHost
      option :id, required: true
      # TODO Validate hostname is valid
      option :hostname, required: true
      option :ssh_port
      option :description

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

    class Localhost < BaseHost

      def working_directory=(value)
        @options[:working_directory] = value
      end

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
        #TODO warn or error on existing host
        hosts[id] = Host.new(options.merge(id: id))
      end

      def get(id)
        return localhost if id == 'localhost' || id == nil
        raise SheepException, "The '#{id}' host is undefined" if hosts[id].nil?
        hosts[id]
      end

      private
      def hosts
        @hosts ||= {}
      end

    end

  end
end
