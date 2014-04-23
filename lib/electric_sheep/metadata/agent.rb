module ElectricSheep
  module Metadata
    class Agent < Base
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

      private
      def ensure_known_agent
        if agent.nil?
          errors.add(:type, "Unknown agent type #{type}")
        end
      end
    end
  end
end
