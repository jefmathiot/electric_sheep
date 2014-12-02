module ElectricSheep
  module Transport
    extend ActiveSupport::Concern
    include Runnable

    def initialize(project, logger, metadata, hosts)
      @project = project
      @logger = logger
      @metadata = metadata
      @hosts = hosts
    end

    def run!
      local_interactor.in_session do
        remote_interactor.in_session do
          log_run
          if host(option(:to)).local?
            handling_input(remote_interactor) do
              remote_interactor.download! input, output, local_interactor
            end
          else
            handling_input(local_interactor) do
              remote_interactor.upload! input, output, local_interactor
            end
          end
          done! output
        end
      end
    end

    protected

    def done!(output)
      stat!(output, output.local? ? local_interactor : remote_interactor)
      super move? ? output : input
    end

    def handling_input(from, &block)
      stat!(input, from)
      yield
      from.delete!(input) if move?
    end

    def move?
      @metadata.type == :move
    end

    def log_run
      logger.info "#{move? ? 'Moving' : 'Copying'} " +
        "#{input.name} to #{option(:to)} using #{option(:transport)}"
    end

    def output
      @output ||= if input.local?
        remote_resource
      else
        local_resource
      end
    end

    def local_interactor
      @local_interactor ||= Interactors::ShellInteractor.new(
        @hosts.localhost, @project, @logger
      )
    end

    def local_resource
      file_resource(host('localhost'))
    end

    def remote_interactor
      raise "Not implemented, please define #{self.class}#remote_interactor"
    end

    def remote_resource
      raise "Not implemented, please define #{self.class}#remote_resource"
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
