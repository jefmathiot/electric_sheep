module ElectricSheeps
    module Metadata
        class Project
            attr_reader :description

            def initialize(options={})
                @description = options[:description]
            end
        end
    end
end
