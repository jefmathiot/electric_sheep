module ElectricSheeps
    module Metadata
        class Project
            include Queueable

            def initialize
                reset!
            end

            include Options
            optionize :description
        end
    end
end
