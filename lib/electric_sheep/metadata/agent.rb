module ElectricSheep
  module Metadata
    class Agent < Base

      option :action, required: true

      def validate(config)
        ensure_known_agent
        super
      end

      def options
        unless agent.nil?
          agent.options.merge(super)
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

    end
  end
end
