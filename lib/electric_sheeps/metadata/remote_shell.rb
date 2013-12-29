module ElectricSheeps
    module Metadata
        class RemoteShell < Shell
            attr_reader :host

            def initialize(options={})
                super()
                @host = options[:host]
            end
        end
    end
end
