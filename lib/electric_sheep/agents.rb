require 'electric_sheep/command'

module ElectricSheep
  module Agents
    module Register
      def self.register(options={})
        type = options.has_key?(:command) ? :command : :transport
        store.add type, options.delete(type), options
      end

      def self.command(id)
        store.command(id)
      end

      def self.transport(id)
        store.transport(id)
      end

      private
      def self.store
        @store ||= Store.new
      end

      class Store

        def initialize
          @agents = {command: {}, transport: {}}
        end

        def add(type, klazz, options)
          @agents[type][options[:as].to_sym]=klazz
        end

        def command(id)
          @agents[:command][id.to_sym]
        end

        def transport(id)
          @agents[:transport][id.to_sym]
        end

      end
    end
  end
end
