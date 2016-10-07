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
      # TODO: Validate hostname is valid
      option :hostname, required: true
      option :ssh_port
      option :description
      option :private_key
      option :private_key_data

      def initialize(options = {})
        options[:ssh_port] ||= 22
        super
      end

      def local?
        false
      end

      def to_s
        id
      end

      def to_location
        Metadata::Pipe::Location.new(id, hostname, :host)
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
        'localhost'
      end

      def hostname
        @hostname ||= `hostname`.chomp
      end

      def to_location
        Metadata::Pipe::Location.new(to_s, hostname, :host)
      end
    end

    class Hosts
      def localhost
        @localhost ||= Localhost.new
      end

      def add(id, options)
        # TODO: warn or error on existing host
        all[id] = Host.new(options.merge(id: id))
      end

      def get(id)
        return localhost if id == 'localhost' || id.nil?
        raise SheepException, "The '#{id}' host is undefined" if all[id].nil?
        all[id]
      end

      def all
        @hosts ||= {}
      end
    end
  end
end
