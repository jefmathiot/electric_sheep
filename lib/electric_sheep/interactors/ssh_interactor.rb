module ElectricSheep
  module Interactors
    class SshInteractor < Base
      include Helpers::ShellStat

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

      def upload!(from, to, local)
        source, target = local.expand_path(from.path), expand_path(to.path)
        copy_paths( source, target, self, from.directory? ) do |source, target|
          scp.upload! source, target, recursive: from.directory?
        end
      end

      def download!(from, to, local)
        source, target = expand_path(from.path), local.expand_path(to.path)
        copy_paths( source, target, local, from.directory? ) do |source, target|
          scp.download! source, target, recursive: from.directory?
        end
      end

      protected

      def build_session
        Net::SSH.start(
          @host.hostname,
          @user,
          port: @host.ssh_port,
          key_data: Crypto.get_key(private_key, :private).export,
          keys_only: true
        )
      end

      def private_key
        @host.private_key || @project.private_key
      end

      def copy_paths(source, target, context, directory, &block)
        if directory
          to_tmpdir(source, target, context) do |path|
            yield source, path
          end
        else
          yield source, target
        end
      end

      def to_tmpdir(source, target, context, &block)
        path=tmpdir(source, target)
        File.expand_path(File.join(path, '..')).tap do |parent|
          context.exec "mkdir #{parent}"
          yield parent
          context.exec "mv #{path} #{target}"
          context.exec "rm -rf #{parent}"
        end
      end

      def tmpdir(source, target)
        t = Time.now.strftime("%Y%m%d")
        File.join(
          File.dirname(target),
          "tmp#{t}-#{$$}-#{rand(0x100000000).to_s(36)}",
          File.basename(source)
        )
      end
    end
  end
end
