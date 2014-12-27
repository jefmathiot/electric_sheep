module ElectricSheep
  module Metadata
    class Transport < Agent
      include Monitor

      option :transport, required: true
      option :to, required: true

      def copy?
        action == :copy
      end

      def move?
        action == :move
      end

      def agent
        @options[:transport] && Agents::Register.transport(@options[:transport])
      end

      private
      def ensure_known_agent
        if agent.nil?
          errors.add(:transport, "Unknown transport #{transport}")
        end
      end
    end
  end
end
