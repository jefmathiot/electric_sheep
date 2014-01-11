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
                instance_eval &block if block_given?
            end

            def remotely(options, &block)
                @project.add RemoteShellDsl.new(host: @config.hosts.get(options[:on]), &block).shell
            end

            def locally(&block)
                @project.add ShellDsl.new(&block).shell
            end

            def transport(type, &block)
                @project.add TransportDsl.new(&block).transport
            end

            def method_missing(*args)
                # Avoids the options parsed by Optionizer to raise exceptions
            end
        end

        class ShellDsl
            attr_reader :shell

            def initialize(options={}, &block)
                @shell = new_shell(options)
                instance_eval &block if block_given?
            end

            def command(agent, options={}, &block)
                id = options[:as] || agent
                @shell.add ElectricSheeps::Metadata::Command.new(id: id, agent: agent)
            end
            
            protected
            def new_shell(options)
                Metadata::Shell.new
            end
        end

        class RemoteShellDsl < ShellDsl
            protected
            def new_shell(options)
                Metadata::RemoteShell.new(options)
            end
        end

        class TransportDsl
            attr_reader :transport

            def initialize(options={}, &block)
                @transport = Metadata::Transport.new(options)
                instance_eval &block if block_given?
            end
        end
    end
end
