module ElectricSheep
  module Metadata
    class Command < Base
      include Metered
              
      option :id, required: true
      option :type, required: true

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

      def options
        unless command_runner.nil?
          command_runner.options.merge(super)
        else
          super
        end
      end

    end
  end
end
