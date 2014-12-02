module ElectricSheep
  module Command
    extend ActiveSupport::Concern
    include Runnable

    attr_reader :shell
    delegate :stat_file, :stat_directory, :stat_filesystem, to: :shell

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

    def host
      shell.host
    end

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
