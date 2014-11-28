module ElectricSheep
  module Command
    extend ActiveSupport::Concern
    include Runnable

    attr_reader :shell

    def initialize(project, logger, shell, metadata)
      @project = project
      @logger = logger
      @shell = shell
      @metadata = metadata
    end

    def check_prerequisites
      self.class.prerequisites.each { |prerequisite|
        self.send prerequisite
      }
    end

    def run!
      stat!(input)
      perform!
    end

    protected

    def done!(output)
      stat!(output)
      super
    end

    def file_resource(opts={})
      filesystem_resource(:file, opts)
    end

    def directory_resource(opts={})
      filesystem_resource(:directory, opts)
    end

    def filesystem_resource(type, opts={})
      Resources.const_get(type.to_s.camelize).new(
        opts.merge(
          basename: input.basename,
          host: shell.host
        )
      ).tap do |resource|
        resource.timestamp!(input)
      end
    end

    def stat_filesystem(resource)
      shell.exec("du -bs #{shell.expand_path(resource.path)} | cut -f1")[:out].chomp.to_i
    end

    alias :stat_file :stat_filesystem
    alias :stat_directory :stat_filesystem

    def stat!(resource)
      resource.stat!(send("stat_#{resource.type}", resource)) if resource.stat.size.nil?
      rescue Exception => e
        logger.debug "Unable to stat resource of type #{resource.type}: #{e.message}"
    end

    module ClassMethods
      def register(options={})
        ElectricSheep::Agents::Register.register(options.merge(command: self))
      end

      def prerequisite(*args)
        @prerequisites = args.dup
      end

      def prerequisites
        @prerequisites ||= []
      end
    end

  end
end

