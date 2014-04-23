module ElectricSheep
  module Metadata
    class Command < Agent
      include Metered
              
      option :id, required: true
      option :type, required: true

      def agent
        @options[:type] && Agents::Register.command(@options[:type])
      end
      
    end
  end
end
