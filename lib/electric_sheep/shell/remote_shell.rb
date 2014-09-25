module ElectricSheep
  module Shell
    class RemoteShell < Base
      include Helpers::Resourceful

      attr_reader :host

      def initialize(logger, host, user, project)
        @logger = logger
        @host = host
        @user = user
        @project=project
      end

      def remote?
        true
      end

      def local?
        false
      end

      def open!
        self if opened?
        @logger.info "Starting a remote shell session for " +
          "#{@user}@#{host.hostname} on port #{host.ssh_port}"
        @interactor = Interactors::SshInteractor.new(host, @user, @project)
        @interactor.session
        self
      end

      def close!
        @interactor.session.close
        @interactor=nil
        self
      end

    end
  end
end
