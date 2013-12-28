module ElectricSheeps
    module Metadata

        class Hosts
            def initialize
                @host = Struct.new(:id, :name, :description)
            end

            def add(options)
                # TODO Validate options[:name] is a valid hostname
                id = options[:id] || options[:name]
                host = @host.new(id, options[:name], options[:description])
                hosts[host.id] = host
            end

            def get(id)
                hosts[id]
            end

            private
            def hosts
                @hosts ||= {}
            end

        end

    end
end
