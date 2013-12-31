module ElectricSheeps
    module Metadata
        class Shell
            include Queueable

            def initialize
                reset!
            end
        end
    end
end
