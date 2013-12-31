module ElectricSheeps
    module Metadata
        class Shell
            include Queue

            def initialize
                reset!
            end
        end
    end
end
