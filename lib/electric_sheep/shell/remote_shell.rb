require 'net/ssh'

module ElectricSheep
  module Shell
    class RemoteShell
      include Directories
      include Resourceful

      def initialize(logger, host, user, private_key)
        @logger = logger
        @host = host
        @user = user
        @private_key = private_key
      end

      def remote?
        true
      end

      def local?
        false
      end

      def open!
        self if opened?
        @logger.info "Starting a remote shell session for #{@user}@#{@host.hostname}"
        @ssh_session = Net::SSH.start(@host.hostname, @user,
          key_data: Crypto.get_key(@private_key, :private).export,
          keys_only: true)
        self
      end

      def exec(cmd)
        result = {out: '', err: '', exit_status: 0}
        @ssh_session.open_channel do |channel|
          channel.exec(cmd) do |ch, success|
            unless success
              @logger.error "Could not execute command #{cmd}"
            end
            channel.on_data do |ch, data|
              result[:out] << data
              @logger.info data
            end
            channel.on_extended_data do |ch, type, data|
              result[:err] << data
              @logger.error data
            end
            channel.on_request('exit-status') do |ch, data|
              result[:exit_status] = data.read_long
            end
          end
        end
        @ssh_session.loop
        [:out, :err].each do |key|
          result[key] = result[key].chomp
        end
        result
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
