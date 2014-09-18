module ElectricSheep
  module Transport
    extend ActiveSupport::Concern
    include Metadata::Options
    include Agent

    def initialize(project, logger, metadata, hosts)
      @project = project
      @logger = logger
      @metadata = metadata
      @hosts = hosts
    end

    def perform
      self.send(@metadata.type)
    end

    def resolve_host(id)
      return @hosts.localhost if id.nil?
      @hosts.get(id)
    end

    module ClassMethods
      def register(options={})
        ElectricSheep::Agents::Register.register(options.merge(transport: self))
      end
    end

  end
end
