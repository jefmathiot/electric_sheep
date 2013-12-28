module ElectricSheeps
    module Metadata
        class Exec
            attr_reader :id, :agent

            def initialize(id, agent)
                @id = id
                @agent = agent
            end
        end
    end
end
