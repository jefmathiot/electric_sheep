module ElectricSheeps
    module Metadata
        class Command
            include Options

            optionize :id, :agent

            attr_accessor :database

        end
    end
end
