module ElectricSheep
  module Interactors
    class SshInteractor < Base
      delegate :upload!, to: :session
      delegate :download!, to: :session

      def initialize(host, user, private_key)
        @host=host
        @user=user
        @private_key=private_key
      end

      def session
        @session||=Net::SSH.start(
          @host.hostname,
          @user,
          port: @host.ssh_port,
          key_data: Crypto.get_key(@private_key, :private).export,
          keys_only: true
        )
      end

      def exec(cmd, logger=nil)
        result = {out: '', err: '', exit_status: 0}
        session.open_channel do |channel|
          channel.exec(cmd) do |ch, success|
            unless success
              logger.error "Could not execute command #{cmd}" if logger
            end
            channel.on_data do |ch, data|
              result[:out] << data
              logger.info data if logger
            end
            channel.on_extended_data do |ch, type, data|
              result[:err] << data
              logger.error data if logger
            end
            channel.on_request('exit-status') do |ch, data|
              result[:exit_status] = data.read_long
            end
          end
        end
        session.loop
        [:out, :err].each do |key|
          result[key] = result[key].chomp
        end
        result
      end

    end
  end
end
