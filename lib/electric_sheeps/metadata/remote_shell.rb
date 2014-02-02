module ElectricSheeps
    module Metadata
        class RemoteShell < Shell
            
            def initialize
                super()
            end
            
            include Options
            optionize :host, :user

        end
    end
end
