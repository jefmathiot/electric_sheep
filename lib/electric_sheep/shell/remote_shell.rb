module ElectricSheep
  module Shell
    class RemoteShell < Base

      def initialize(host, project, logger, user)
        super(host, project, logger)
        @user = user
      end

      def interactor
        @interactor ||= Interactors::SshInteractor.new(
          @host,
          @project,
          @user,
          @logger
        )
      end

      def perform!(metadata)
        @logger.info "Starting a remote shell session for " +
          "#{@user}@#{host.hostname} on port #{host.ssh_port}"
        super
      end

    end
  end
end
