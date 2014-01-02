module ElectricSheeps
    module Metadata
        class Project
            include Queue

            def initialize
                reset!
            end

            include Options
            optionize :id, :description
        end
    end
end
