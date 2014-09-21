module ElectricSheep
  module Shell
    class RemoteShell
      include Directories
      include Helpers::Resourceful
      include Helpers::SSH

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
        @logger.info "Starting a remote shell session for #{@user}@#{host.hostname} on port #{host.ssh_port}"
        @ssh_session = ssh_session host, @user, @project.private_key
        self
      end

      def exec(cmd)
        ssh_exec(@ssh_session, cmd, @logger)
      end

      def close!
        @ssh_session.close
        @ssh_session = nil
        self
      end

      def opened?
        !!@ssh_session
      end

    end
  end
end
