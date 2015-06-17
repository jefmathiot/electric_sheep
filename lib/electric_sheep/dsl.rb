module ElectricSheep
  class Dsl
    module RaiseOnMethodMissing
      def method_missing(method, *_args, &_)
        fail SheepException, "Unknown command '#{method}' in Sheepfile"
      end
    end

    module Encrypted
      def encrypted(value)
        Metadata::Encrypted.new(@config.decryption_options, value)
      end
    end

    include RaiseOnMethodMissing
    include Encrypted

    attr_reader :config

    def initialize(config)
      @config = config
    end

    def host(id, options = {})
      @config.hosts.add id, options
    end

    def job(id, options = {}, &block)
      @config.add JobDsl.new(@config, id, options, &block).job
    end

    def working_directory(dir)
      @config.hosts.localhost.working_directory = dir
    end

    def defaults_for(options = {})
      Agents::Register.assign_defaults_for(options)
    end

    def encrypt(options = {})
      @config.encryption_options = Metadata::EncryptOptions.new(options)
    end

    def decrypt(options = {})
      @config.decryption_options = Metadata::EncryptOptions.new(options)
    end

    class AbstractDsl
      include RaiseOnMethodMissing
      include Encrypted

      class << self
        def returning(property)
          define_method property do
            @subject
          end
        end
      end

      def initialize(*args, &block)
        @config = args.first
        build(*args)
        instance_eval(&block) if block_given?
      end
    end

    class JobDsl < AbstractDsl
      returning :job

      def build(_config, id, options, &_)
        @subject = Metadata::Job.new(options.merge(id: id))
      end

      def remotely(options, &block)
        @subject.add RemoteShellDsl.new(@config, options, &block).shell
      end

      def locally(&block)
        @subject.add ShellDsl.new(@config, &block).shell
      end

      def copy(options)
        transport(:copy, options)
      end

      def move(options)
        transport(:move, options)
      end

      def notify(options)
        options[:agent] = options.delete(:via)
        @subject.notifier Metadata::Notifier.new(options)
      end

      def resource(type, options = {})
        options[:host] = @config.hosts.get(options[:host])
        begin
          resource_klass = Resources.const_get(type.to_s.camelize)
        rescue
          raise SheepException, "Resource '#{type}' in Sheepfile is undefined"
        end
        @subject.start_with! resource_klass.new(options)
      end

      def schedule(type, options = {})
        Metadata::Schedule.const_get(type.capitalize).tap do |klazz|
          @subject.schedule! klazz.new(options)
        end
      end

      private

      def transport(action, options)
        options[:agent] = options.delete(:using)
        options[:to] = options[:to]
        @subject.add Metadata::Transport.new(options.merge(action: action))
      end
    end

    class ShellDsl < AbstractDsl
      returning :shell

      def build(_config, options = {}, &_)
        @subject = new_shell(options)
      end

      def encrypt(options = {})
        key = @config.encryption_options.option(:with)
        opts = { agent: 'encrypt', public_key: key }.merge(options)
        @subject.add Metadata::Command.new(opts)
      end

      def method_missing(method, *args, &_)
        if Agents::Register.command(method)
          opts = { agent: method }.merge(args.first || {})
          @subject.add Metadata::Command.new(opts)
        else
          super
        end
      end

      protected

      def new_shell(_)
        Metadata::Shell.new
      end
    end

    class RemoteShellDsl < ShellDsl
      protected

      def new_shell(options)
        opts = { user: options[:as] }
        Metadata::RemoteShell.new(opts)
      end
    end
  end
end
