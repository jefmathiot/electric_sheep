module ElectricSheeps
  module Metadata
    class Command
      include Options
      include Metered

      options :id, :type

      def agent
        Commands::Register.command(type)
      end

      def add_resource(id, value)
        resources[id] = value
      end

      def method_missing(method, *args, &block)
        if resources.has_key?(method)
          resources[method]
        else
          super
        end
      end

      def resources
        @resources ||= {}
      end
    end
  end
end
