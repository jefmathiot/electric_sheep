module ElectricSheep
  module Interactors
    class SshInteractor < Base

      def initialize(host, project, user, logger=nil)
        super(host, project, logger)
        @user=user
      end

      def exec(cmd)
        @logger.debug cmd if @logger
        after_exec do
          result = {out: '', err: '', exit_status: 0}
          session.open_channel do |channel|
            channel.exec(cmd) do |ch, success|
              unless success
                result[:exit_status] = 1
                result[:err] << "Could not execute command #{cmd}"
              end
              channel.on_data do |ch, data|
                result[:out] << data
                @logger.debug result[:out] if @logger
              end
              channel.on_extended_data do |ch, type, data|
                result[:err] << data
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

      def close
        session.close
      end

      def scp
        session.scp
      end

      protected
      def build_session
        Net::SSH.start(
          @host.hostname,
          @user,
          port: @host.ssh_port,
          key_data: Crypto.get_key(@project.private_key, :private).export,
          keys_only: true
        )
      end

    end
  end
end
