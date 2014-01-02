module ElectricSheeps
    class Dsl
        attr_reader :config

        def initialize(config)
            @config = config
        end

        def host(id, &block)
            @config.hosts.add( Optionizer.optionize([:name, :description], id: id, &block ) )
        end

        def project(id, &block)
            @config.add ProjectDsl.new( @config, id, &block ).project
        end

        class Optionizer
            attr_reader :options

            def initialize(attributes)
                @attributes = attributes
                @options = {}
            end

            def method_missing(method, *args, &block)
                if @attributes.include?( method )
                    @options[method]=args.first
                end
            end

            class << self
                def optionize(attributes, additional={}, &block)
                    optionizer = Optionizer.new(attributes)
                    optionizer.instance_eval( & block ) if block_given?
                    optionizer.options.merge(additional)
                end
            end
        end

        class ProjectDsl

            attr_reader :project

            def initialize(config, id, &block)
                @config = config
                @project = Metadata::Project.new( Optionizer.optionize([:description], id: id, &block)  )
                instance_eval &block
            end

            def remotely(options, &block)
                @project.add Metadata::RemoteShell.new(host: @config.hosts.get(options[:on]))
            end

            def method_missing(*args)
            end
        end
    end
end
