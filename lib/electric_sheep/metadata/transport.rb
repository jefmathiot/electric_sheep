module ElectricSheep
  module Metadata
    class Transport < Agent
      include Metered

      option :transport, required: true
      option :type, required: true # move or copy
      option :to, required: true
      option :as

      def copy?
        type == :copy
      end

      def move?
        type == :move
      end

      def agent
        @options[:transport] && Agents::Register.transport(@options[:transport])
      end

    end
  end
end
