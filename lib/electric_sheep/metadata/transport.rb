module ElectricSheep
  module Metadata
    class Transport < Base
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

    end
  end
end
