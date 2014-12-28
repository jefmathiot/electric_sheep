module ElectricSheep
  module Transport
    extend ActiveSupport::Concern
    include Runnable

    def initialize(project, logger, hosts, input, metadata)
      @project = project
      @logger = logger
      @input = input
      @metadata = metadata
      @hosts = hosts
    end

    def run!
      local_interactor.in_session do
        remote_interactor.in_session do
          log_run
          if input.local?
            handling_input(local_interactor) do
              remote_interactor.upload! input, output, local_interactor
            end
          else
            handling_input(remote_interactor) do
              remote_interactor.download! input, output, local_interactor
            end
          end
          stat!(output, output.local? ? local_interactor : remote_interactor)
        end
      end
      output
    end

    def product
      move? ? output : input
    end

    def output
      @output ||= if input.local?
        remote_resource
      else
        local_resource
      end
    end

    protected

    def handling_input(from, &block)
      stat!(input, from)
      yield
      if move?
        from.delete!(input)
        input.transient!
      end
    end

    def stat!(resource, interactor)
      resource.stat! interactor.stat(resource)
    rescue Exception => e
      logger.warn "Unable to stat resource of type #{resource.type}: #{e.message}"
    end

    def move?
      @metadata.action == :move
    end

    def log_run
      logger.info "#{move? ? 'Moving' : 'Copying'} " +
        "#{input.name} to #{option(:to)} using #{option(:agent)}"
    end

    def local_interactor
      @local_interactor ||= Interactors::ShellInteractor.new(
        @hosts.localhost, @project, @logger
      )
    end

    def local_resource
      send("#{input.type}_resource", host('localhost'))
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
