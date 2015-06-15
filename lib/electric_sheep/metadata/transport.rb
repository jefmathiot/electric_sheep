module ElectricSheep
  module Metadata
    class Transport < Agent
      include Monitor

      option :action, required: true
      option :to, required: true

      def copy?
        action == :copy
      end

      def move?
        action == :move
      end
    end
  end
end
