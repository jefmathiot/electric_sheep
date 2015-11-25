module ElectricSheep
  module Metadata
    class Agent < Configured
      include Typed

      option :agent, required: true

      def validate
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

      def agent_klazz
        # Use the instance variable to avoid stack level too deep
        @options[:agent] && Agents::Register.send(type, @options[:agent])
      end

      protected

      def fetch_option(name)
        explicit_option(name) || register_default_option(name) ||
          default_option(name)
      end

      private

      def register_default_option(name)
        @options[:agent] && Agents::Register
          .defaults_for(type, @options[:agent])[name]
      end

      def ensure_known_agent
        return unless agent_klazz.nil?
        errors.add(type.to_sym, "Unknown #{type} \"#{agent}\"")
      end
    end
  end
end
