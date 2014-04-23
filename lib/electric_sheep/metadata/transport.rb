module ElectricSheep
  module Metadata
    class Transport < Agent
      include Metered

      option :type, required: true
      option :transport, required: true
      option :to, required: true
      
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
