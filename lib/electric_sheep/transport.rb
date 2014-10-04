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
    def file_resource(host, opts={})
      file_system_resource(:file, host, opts)
    end

    def directory_resource(host, opts={})
      file_system_resource(:directory, host, opts)
    end

    def file_system_resource(type, host, opts={})

      Resources.const_get(type.to_s.camelize).new(
        opts.merge(
          extension: input.respond_to?(:extension) && input.extension || nil,
          basename: input.basename,
          host: host
        )
      ).tap do |resource|
        resource.timestamp!(input)
      end
    end

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
