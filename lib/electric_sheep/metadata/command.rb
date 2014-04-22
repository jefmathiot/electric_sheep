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
        @options[:type] && Commands::Register.command(@options[:type])
      end
      
      def ensure_known_command
        if command_runner.nil?
          errors.add(:type, "Unknown command type #{type}")
        end
      end

      def properties
        unless command_runner.nil?
          command_runner.properties.merge(super)
        else
          super
        end
      end

    end
  end
end
