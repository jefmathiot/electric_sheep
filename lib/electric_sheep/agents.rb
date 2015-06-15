require 'electric_sheep/agent'
require 'electric_sheep/runnable'
require 'electric_sheep/command'
require 'electric_sheep/transport'

module ElectricSheep
  module Agents
    module Register
      AGENT_TYPES = [:command, :notifier, :transport].freeze

      class << self
        delegate :defaults_for, to: :store

        def register(options = {})
          store.add(*registration_args(options))
        end

        def assign_defaults_for(options = {})
          store.assign_defaults_for(*registration_args(options))
        end

        AGENT_TYPES.each do |type|
          define_method type do |id|
            store.agent(type, id)
          end
        end

        private

        def registration_args(options)
          AGENT_TYPES.each do |type|
            return type, options.delete(type), options if options.key?(type)
          end
        end

        def store
          @store ||= Store.new(AGENT_TYPES)
        end
      end

      class Store
        def initialize(types)
          @agents = agent_hash(types)
          @defaults = agent_hash(types)
        end

        def add(type, klazz, options)
          @agents[type][options[:as].to_sym] = klazz
        end

        def assign_defaults_for(type, id, options)
          if @agents[type][id].nil?
            fail "Can't assign default options for the unknown #{type} #{id}"
          end
          type_defaults(type)[id] = options
        end

        def defaults_for(type, id)
          defaults = type_defaults(type)[id]
          defaults && defaults.dup || {}
        end

        def agent(type, id)
          @agents[type][id]
        end

        private

        def type_defaults(type)
          @defaults[type]
        end

        def agent_hash(types)
          types.each_with_object({}.with_indifferent_access) do |key, h|
            h[key] = {}.with_indifferent_access
          end
        end
      end
    end
  end
end
