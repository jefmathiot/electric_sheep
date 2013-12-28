module ElectricSheeps
    module Metadata
        class RemoteShell < Shell
            attr_reader :host

            def initialize(host)
                super()
                @host = host
            end
        end
    end
end
