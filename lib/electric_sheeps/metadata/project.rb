module ElectricSheeps
    module Metadata
        class Project
            include Queue

            def initialize
                reset!
            end

            include Options
            optionize :description
        end
    end
end
