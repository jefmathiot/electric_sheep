module ElectricSheep
  module Metadata
    class Agent < Base
      include Typed

      option :agent, required: true

      def validate(config)
        ensure_known_agent
        super
      end

      def options
        unless agent_klazz.nil?
          agent_klazz.options.merge(super)
        else
          super
        end
      end

      def safe_option(name)
        value=option(name)
        if value && options[name][:secret]
          return '****'
        end
        value
      end

      def agent_klazz
        # Use the instance variable to avoid stack level too deep
        @options[:agent] && Agents::Register.send(type, @options[:agent])
      end

      private
      def ensure_known_agent
        if agent_klazz.nil?
          errors.add(type.to_sym, "Unknown #{type} \"#{agent}\"")
        end
      end

    end
  end
end
