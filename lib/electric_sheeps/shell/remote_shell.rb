require 'net/ssh'

module ElectricSheeps
  module Shell
    class RemoteShell

      def initialize(logger, host, user)
        @logger = logger
        @host = host
        @user = user
      end

      def remote?
        true
      end

      def local?
        false
      end

      def open!
        self if opened?
        @logger.info "Starting a remote shell session for #{@user}@#{@host}"
        @ssh_session = Net::SSH.start(@host, @user)
        self
      end

      def exec(cmd)
        exit_status = 0
        @ssh_session.open_channel do |channel|
          channel.exec(cmd) do |ch, success|
            unless success
              @logger.error "Could not execute command #{cmd}"
            end
            channel.on_data do |ch, data|
              @logger.info data
            end
            channel.on_extended_data do |ch, type, data|
              @logger.error data
            end
            channel.on_request('exit-status') do |ch, data|
              exit_status = data.read_long
            end
          end
        end
        @ssh_session.loop
        exit_status
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
