module ElectricSheeps
    module Metadata
        class Exec
            attr_reader :id, :agent

            def initialize(options={})
                @id = options[:id]
                @agent = options[:agent]
            end
        end
    end
end
