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
        raise "Missing #{prerequisite} in #{self.class}" unless self.respond_to?(prerequisite)
        self.send prerequisite
      }
    end

    protected
    def file_resource(opts={})
      file_system_resource(:file, opts)
    end

    def directory_resource(opts={})
      file_system_resource(:directory, opts)
    end

    def file_system_resource(type, opts={})
      Resources.const_get(type.to_s.camelize).new(
        opts.merge(
          basename: input.basename,
          host: shell.host
        )
      ).tap do |resource|
        resource.timestamp!(input)
      end
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

