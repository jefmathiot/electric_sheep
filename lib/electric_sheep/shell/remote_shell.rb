module ElectricSheep
  module Shell
    class RemoteShell < Base
      # TODO: enable this check, as soon as logger becomes global
      # rubocop:disable Metrics/ParameterLists
      def initialize(host, job, input, user, ssh_options, logger)
        # rubocop:enable Metrics/ParameterLists
        super(host, job, input, logger)
        @user = user
        @ssh_options = ssh_options
      end

      def interactor
        @interactor ||= Interactors::SshInteractor.new(
          @host,
          @job,
          @user,
          @ssh_options,
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
