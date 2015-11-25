module ElectricSheep
  module Metadata
    class Shell < Configured
      include Pipe
      include Monitor

      def validate
        iterate do |command|
          unless command.validate
            errors.add :base, "Invalid command \"#{command.agent}\"",
                       command.errors
          end
        end
        super
      end
    end
  end
end
