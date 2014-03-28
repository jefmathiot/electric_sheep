module ElectricSheeps
  module Agents
    module Agent 
      extend ActiveSupport::Concern

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
