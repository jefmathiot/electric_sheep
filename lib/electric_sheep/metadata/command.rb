module ElectricSheep
  module Metadata
    class Command < Agent
      include Metered
              
      option :id, required: true
      option :type, required: true

      def self.agent_type
        :command
      end

    end
  end
end
