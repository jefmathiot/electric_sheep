module ElectricSheeps
  module Agents
    module Agent 
      extend ActiveSupport::Concern

      attr_reader :logger, :shell

      def run(metadata)
        @logger, @shell = metadata[:logger], metadata[:shell]
        perform
      end

      module ClassMethods
        def register(options={})
          ElectricSheeps::Agents::Register.register(self, options)
        end

        def resource(name, options={})
          resources[name]= options[:of_type] || Resources::File
        end

        def resources
          @resources ||= {}
        end

      end 
    end
  end
end
