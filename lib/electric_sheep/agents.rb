require 'electric_sheep/agent'
require 'electric_sheep/runnable'
require 'electric_sheep/command'
require 'electric_sheep/transport'

module ElectricSheep
  module Agents
    module Register

      AGENT_TYPES=[:command, :notifier, :transport].freeze

      class << self

        def register(options={})
          store.add *registration_args(options)
        end

        AGENT_TYPES.each do |type|
          define_method type do |id|
            store.agent(type, id)
          end
        end

        private
        def registration_args(options)
          AGENT_TYPES.each do |type|
            if options.has_key?(type)
              return type, options.delete(type), options
            end
          end
        end

        def store
          @store ||= Store.new
        end
      end

      class Store

        def initialize
          @agents = {command: {}, transport: {}, notifier: {}}
        end

        def add(type, klazz, options)
          @agents[type][options[:as].to_sym]=klazz
        end

        def agent(type, id)
          @agents[type][id.to_sym]
        end

      end
    end
  end
end
