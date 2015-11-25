module ElectricSheep
  module Shell
    class RemoteShell < Base
      def initialize(host, job, input, user, logger)
        # rubocop:enable Metrics/ParameterLists
        super(host, job, input, logger)
        @user = user
      end

      def interactor
        @interactor ||= Interactors::SshInteractor.new(
          @host,
          @job,
          @user,
          @logger
        )
      end

      def perform!(metadata)
        @logger.info 'Starting a remote shell session for ' \
          "#{@user}@#{host.hostname} on port #{host.ssh_port}"
        super
      end
    end
  end
end
