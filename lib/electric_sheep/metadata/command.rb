module ElectricSheep
  module Metadata
    class Command < Agent
      include Monitor

      def agent
        @options[:action] && Agents::Register.command(@options[:action])
      end

      private
      def ensure_known_agent
        if agent.nil?
          errors.add(:action, "Unknown command #{action}")
        end
      end

    end
  end
end
