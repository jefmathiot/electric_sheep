module ElectricSheeps
    module Metadata
        class Project

            def initialize
                @steps = []
                reset!
            end

            def add(step)
                @steps << step
                step
            end

            def size
                @steps.size
            end

            def remaining
                [@steps.size - @current, 0].max
            end

            def next!
                @current += 1
                @steps[@current - 1]
            end

            private
            def reset!
                @current = 0
            end

            include Options
            optionize :description
        end
    end
end
