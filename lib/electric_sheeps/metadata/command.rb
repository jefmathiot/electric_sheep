module ElectricSheeps
    module Metadata
        class Command
            include Options

            optionize :id, :agent

        end
    end
end
