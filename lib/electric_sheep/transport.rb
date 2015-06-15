module ElectricSheep
  module Transport
    extend ActiveSupport::Concern
    include Runnable

    def initialize(job, logger, hosts, input, metadata)
      @job = job
      @logger = logger
      @input = input
      @metadata = metadata
      @hosts = hosts
    end

    def run!
      in_sessions do
        input.local? ? perform_upload : perform_download
      end
      output
    end

    def product
      move? ? output : input
    end

    def output
      @output ||= input.local? ? remote_resource : local_resource
    end

    protected

    def in_sessions(&_)
      local_interactor.in_session do
        remote_interactor.in_session do
          log_run
          yield
          stat!(output, output.local? ? local_interactor : remote_interactor)
        end
      end
    end

    def perform_upload
      handling_input(local_interactor) do
        remote_interactor.upload! input, output, local_interactor
      end
    end

    def perform_download
      handling_input(remote_interactor) do
        remote_interactor.download! input, output, local_interactor
      end
    end

    def handling_input(from, &_)
      stat!(input, from)
      yield
      return unless move?
      from.delete!(input)
      input.transient!
    end

    def stat!(resource, interactor)
      resource.stat! interactor.stat(resource)
    rescue Exception => e
      logger.warn 'Unable to stat resource of type ' \
        "#{resource.type}: #{e.message}"
    end

    def move?
      @metadata.action == :move
    end

    def log_run
      logger.info "#{move? ? 'Moving' : 'Copying'} " \
        "#{input.name} to #{option(:to)} using #{option(:agent)}"
    end

    def local_interactor
      @local_interactor ||= Interactors::ShellInteractor.new(
        @hosts.localhost, @job, @logger
      )
    end

    def local_resource
      send("#{input.type}_resource", host('localhost'))
    end

    def remote_interactor
      fail "Not implemented, please define #{self.class}#remote_interactor"
    end

    def remote_resource
      fail "Not implemented, please define #{self.class}#remote_resource"
    end

    def host(id)
      @hosts.get(id)
    end

    module ClassMethods
      def register(options = {})
        ElectricSheep::Agents::Register.register(options.merge(transport: self))
      end
    end
  end
end
