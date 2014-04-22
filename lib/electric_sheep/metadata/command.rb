module ElectricSheep
  module Metadata
    class Command < Base
      include Metered
              
      property :id, required: true
      property :type, required: true

      def validate(config)
        ensure_known_command
        super
      end

      def command_runner
        type && Commands::Register.command(type)
      end
      
      def ensure_known_command
        if command_runner.nil?
          errors.add(:type, "Unknown command type #{type}")
        end
      end

    end
  end
end
