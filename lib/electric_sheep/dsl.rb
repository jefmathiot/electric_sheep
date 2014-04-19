module ElectricSheep
  class Dsl
    attr_reader :config

    def initialize(config)
      @config = config
    end

    def host(id, options={})
      @config.hosts.add id, options
    end

    def project(id, options={}, &block)
      @config.add ProjectDsl.new( @config, id, options, &block ).project
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

    end

    class ProjectDsl < AbstractDsl

      returning :project

      def build(config, id, options, &block)
        @subject = Metadata::Project.new(options.merge(id: id))
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

      def resource(type, options={})
        @subject.start_with! ElectricSheep::Resources.const_get(type.to_s.camelize).new(options)
      end

      def private_key(path)
        @subject.use_private_key! File.expand_path(path)
      end
    end

    class ShellDsl < AbstractDsl

      returning :shell

      def build(config, options={}, &block)
        @subject = new_shell(options)
      end

      def method_missing(method, *args, &block)
        if Commands::Register.command(method)
          opts = {type: method}.merge(args.first || {})
          @subject.add Metadata::Command.new(opts)
        else
          super
        end
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
