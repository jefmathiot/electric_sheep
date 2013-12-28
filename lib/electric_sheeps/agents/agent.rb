module ElectricSheeps
    module Agents
        module Agent 
            extend ActiveSupport::Concern
           
            module ClassMethods
                def register(options={})
                    ElectricSheeps::Agents::Register.register(self, options)
                end
            end 
        end
    end
end
