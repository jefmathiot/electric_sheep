module ElectricSheep
  module Command
    extend ActiveSupport::Concern
    include Metadata::Options
    include Agent

    attr_reader :shell, :work_dir
    
    def initialize(project, logger, shell, work_dir, metadata)
      @project = project
      @logger = logger
      @shell = shell
      @work_dir = work_dir
      @metadata = metadata
    end
    
    def check_prerequisites
      self.class.prerequisites.each { |prerequisite|
        raise "Missing #{prerequisite} in #{self.class}" unless self.respond_to?(prerequisite)
        self.send prerequisite
      }
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

