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

    module ClassMethods
      def register(options={})
        ElectricSheep::Agents::Register.register(options.merge(transport: self))
      end
    end

  end
end
