module ElectricSheeps
  module Metadata
    class Command
      include Options
      include Metered

      optionize :id, :type

      def agent
        Agents::Register.command(type)
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

      protected
      def resources
        @resources ||= {}
      end

    end
  end
end
