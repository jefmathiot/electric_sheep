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

    end
  end
end
