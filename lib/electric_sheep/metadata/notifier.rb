module ElectricSheep
  module Metadata
    class Notifier < Agent

      option :notifier, required: true

      def agent
        @options[:notifier] && Agents::Register.notifier(@options[:notifier])
      end

      private
      def ensure_known_agent
        if agent.nil?
          errors.add(:notifier, "Unknown notifier #{notifier}")
        end
      end

    end
  end
end
