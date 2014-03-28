module ElectricSheeps
  class Dsl
    attr_reader :config

    def initialize(config)
      @config = config
    end

    def host(id, &block)
      HostDsl.new(@config, id, &block).host
    end

    def project(id, &block)
      @config.add ProjectDsl.new( @config, id, &block ).project
    end

    class AbstractDsl

      class << self
        def returning(property)
          define_method property do
            @subject
          end
        end
      end

      def initialize(*args, &block)
        @config = args.first
        build *args
        instance_eval &block if block_given?
      end

      def method_missing(method, *args, &block)
        if @subject.respond_to? "#{method}="
          @subject.send "#{method}=", args.first
        else
          super
        end
      end
    end

    class HostDsl
      def initialize(config, id, &block)
        @config = config
        @id = id
        instance_eval &block if block_given?
      end

      def name(value)
        @name = value
      end

      def description(value)
        @description = value
      end

      def host
        @config.hosts.add( id: @id, name: @name, description: @description)
      end

    end

    class ProjectDsl < AbstractDsl

      returning :project

      def build(config, id, &block)
        @subject = Metadata::Project.new(id: id)
      end

      def remotely(options, &block)
        @subject.add RemoteShellDsl.new( @config, options, &block).shell
      end

      def locally(&block)
        @subject.add ShellDsl.new(@config, &block).shell
      end

      def transport(type, &block)
        @subject.add TransportDsl.new(@config, &block).transport
      end
    end

    class ShellDsl < AbstractDsl

      returning :shell

      def build(config, options={}, &block)
        @subject = new_shell(options)
      end

      def command(agent, options={}, &block)
        @subject.add CommandDsl.new(@config, agent, options, &block).command
      end

      protected
      def new_shell(options)
        Metadata::Shell.new
      end
    end

    class RemoteShellDsl < ShellDsl
      protected
      def new_shell(options)
        opts = { host: options[:on], user: options[:as] }
        Metadata::RemoteShell.new(opts)
      end
    end

    class CommandDsl < AbstractDsl

      returning :command

      def build(config, agent, options={}, &block)
        opts = {
          id: options[:as] || agent,
          type: agent
        }
        @subject = Metadata::Command.new(opts)
      end

      def method_missing(method, *args, &block)
        if resource = @subject.agent.resources[method]
          @subject.add_resource method, ResourceDsl.new(@config, resource, args.first, &block).resource
        end
      end
    end

    class ResourceDsl < AbstractDsl

      returning :resource

      def build(config, type, name, &block)
        @subject = type.new(name: name)
        instance_eval &block if block_given?
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
