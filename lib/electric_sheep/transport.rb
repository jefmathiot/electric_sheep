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

    def perform
      mk_project_directory!(@hosts.localhost)
      self.send(@metadata.type)
    end

    protected
    def local_interactor
      @local_interactor ||= Interactors::ShellInteractor.new(@project)
    end

    def host(id)
      @hosts.get(id)
    end

    def mk_project_directory!(host, interactor=nil)
      interactor ||= local_interactor
      interactor.in_session do
        directories(host, interactor)
        mk_project_directory!
      end
    end

    def directories(host, interactor)
      Helpers::Directories.new(host, @project, interactor)
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
