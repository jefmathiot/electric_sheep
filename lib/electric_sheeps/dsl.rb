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
                @project = Metadata::Project.new(
                    Optionizer.optionize([:description], id: id, &block)  )
                instance_eval &block if block_given?
            end

            def remotely(options, &block)
                @project.add RemoteShellDsl.new( @config, options, &block).shell
            end

            def locally(&block)
                @project.add ShellDsl.new(@config, &block).shell
            end

            def transport(type, &block)
                @project.add TransportDsl.new(@config, &block).transport
            end

            def method_missing(*args)
                # Avoids the options parsed by Optionizer to raise exceptions
            end
        end

        class ShellDsl
            attr_reader :shell

            def initialize(config, options={}, &block)
                @config = config
                @shell = new_shell(options)
                instance_eval &block if block_given?
            end

            def command(agent, options={}, &block)
                @shell.add CommandDsl.new(@config, agent, options, &block).command
            end
            
            protected
            def new_shell(options)
                Metadata::Shell.new
            end
        end

        class RemoteShellDsl < ShellDsl
            protected
            def new_shell(options)
                opts = { host: @config.hosts.get(options[:on]), user: options[:as] }
                Metadata::RemoteShell.new(opts)
            end
        end

        class CommandDsl
            attr_reader :command

            def initialize(config, agent, options={}, &block)
                @config = config
                options = {
                    id: options[:as] || agent,
                    type: agent
                }
                @command = Metadata::Command.new(options)
                instance_eval &block if block_given?
            end

            def method_missing(method, *args, &block)
                if resource = @command.agent.resources[method]
                    @command.add_resource method, ResourceDsl.new(@config, resource, args.first, &block).resource
                end
            end
        end

        class ResourceDsl
            attr_reader :resource

            def initialize(config, type, name, &block)
                @resource = type.new(name: name)
                instance_eval &block if block_given?
            end

            def method_missing(method, *args, &block)
                if @resource.respond_to?("#{method}=")
                    @resource.send "#{method}=", args.first
                else
                    super
                end
            end
        end

        class TransportDsl
            attr_reader :transport

            def initialize(config, options={}, &block)
                instance_eval &block if block_given?
                @transport = Metadata::Transport.new(options.merge(from: @from, to: @to))
            end

            def from(&block)
                @from = Metadata::TransportEnd.new
            end

            def to(&block)
                @to = Metadata::TransportEnd.new
            end

        end
    end
end
