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
        if agent_klazz
          agent_klazz.options.merge(super)
        else
          super
        end
      end

      def safe_option(name)
        value = option(name)
        return '****' if value && options[name][:secret]
        value
      end

      def option(name)
        super || @options[:agent] && Agents::Register
          .defaults_for(type, @options[:agent])[name]
      end

      def agent_klazz
        # Use the instance variable to avoid stack level too deep
        @options[:agent] && Agents::Register.send(type, @options[:agent])
      end

      private

      def ensure_known_agent
        return unless agent_klazz.nil?
        errors.add(type.to_sym, "Unknown #{type} \"#{agent}\"")
      end
    end
  end
end
