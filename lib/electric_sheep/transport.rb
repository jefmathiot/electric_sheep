module ElectricSheep
  module Transport
    extend ActiveSupport::Concern
    include Metadata::Options
    include Agent
    
    def initialize(project, logger, metadata)
      @project = project
      @logger = logger
      @metadata = metadata
    end

    def perform
      self.send(@metadata.type)
    end

    protected
    def done!(resource)
      @project.store_product!(resource)
    end

    def resource
      @project.last_product
    end

    def option(name)
      option = @metadata.send(name)
      return option.decrypt(@project.private_key) if option.respond_to?(:decrypt)
      option
    end

    module ClassMethods
      def register(options={})
        ElectricSheep::Agents::Register.register(options.merge(transport: self))
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
