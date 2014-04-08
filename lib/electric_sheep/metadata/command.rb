module ElectricSheep
  module Metadata
    class Command
      include Options
      include Metered
              
      options :id, :type

      def command_runner
        Commands::Register.command(type)
      end

    end
  end
end
