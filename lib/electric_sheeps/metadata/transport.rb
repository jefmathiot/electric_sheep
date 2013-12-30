module ElectricSheeps
    module Metadata
        class Transport
            include Options

             optionize :from, :to

        end

        class TransportEnd
            include Options

            optionize :host, :resource

        end
    end
end
