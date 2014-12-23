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

      def type
        'transport'
      end

      private
      def ensure_known_agent
        if agent.nil?
          errors.add(:type, "Unknown transport type #{transport}")
        end
      end
    end
  end
end
