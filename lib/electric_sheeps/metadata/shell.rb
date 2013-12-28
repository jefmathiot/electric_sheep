module ElectricSheeps
    module Metadata
        class Shell

            def initialize
                @execs = []
            end

            def add(exec)
                @execs << exec
            end

            def size
                @execs.size
            end

        end
    end
end
