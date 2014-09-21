require 'net/ssh'

module ElectricSheep
  module Helpers
    module SSH
      def ssh_session(host, user, private_key, &block)
        Net::SSH.start(host.hostname, user,
          port: host.ssh_port,
          key_data: Crypto.get_key(private_key, :private).export,
          keys_only: true,
          &block)
      end

      def ssh_exec(ssh_session, cmd, logger=nil)
        result = {out: '', err: '', exit_status: 0}
        ssh_session.open_channel do |channel|
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
        ssh_session.loop
        [:out, :err].each do |key|
          result[key] = result[key].chomp
        end
        result
      end

      def in_remote_session(host, &block)
        ssh_session host, option(:as), @project.private_key do |ssh|
          block.call ssh
        end
      end

    end
  end
end
