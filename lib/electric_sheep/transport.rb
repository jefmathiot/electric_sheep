require 'electric_sheep/helpers/resourceful'

module ElectricSheep
  module Transport
    extend ActiveSupport::Concern
    include Agent

    def initialize(project, logger, metadata, hosts)
      @project = project
      @logger = logger
      @metadata = metadata
      @hosts = hosts
    end

    def perform!
      # Create a session so that required directories are created
      local_interactor.in_session
      self.send(@metadata.type)
    end

    protected
    def local_interactor
      @local_interactor ||= Interactors::ShellInteractor.new(@hosts.localhost, @project)
    end

    def host(id)
      @hosts.get(id)
    end

    module ClassMethods
      def register(options={})
        ElectricSheep::Agents::Register.register(
          options.merge(transport: self)
        )
      end
    end

  end
end
