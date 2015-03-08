module ElectricSheep
  module Interactors
    class SshInteractor < Base
      include ShellStat

      def initialize(host, job, user, logger=nil)
        super(host, job, logger)
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
          auth_methods: %w(publickey),
          key_data: PrivateKey.get_key(private_key, :private).export,
          keys_only: true
        )
      end

      def private_key
        key = @host.private_key || @job.private_key || '~/.ssh/id_rsa'
        File.expand_path(key)
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
        File.join(
          File.dirname(target),
          Helpers::FSUtil.tempname,
          File.basename(source)
        )
      end

      class PrivateKey

        class << self
          def get_key(keyfile, type)
            ::OpenSSL::PKey::RSA.new(read_keyfile(keyfile)).tap do |key|
              raise "Not a #{type} key: #{keyfile}" unless key.send("#{type}?")
            end
          end

          private
          def read_keyfile(keyfile)
            keyfile=File.expand_path(keyfile)
            raise "Key file not found #{keyfile}" unless File.exists?(keyfile)
            key = File.read(keyfile)
            return openssh_to_pem(keyfile) if openssh?(key)
            return key if pem?(key)
            raise "Key file format not supported"
          end

          def openssh_to_pem(keyfile)
            result = Spawn.exec("ssh-keygen -f #{keyfile} -e -m pem")
            unless result[:exit_status] == 0
              raise "Unable to convert key file #{keyfile} to PEM: " +
              result[:err]
            end
            result[:out]
          end

          def pem?(key)
            key =~ /\A-----BEGIN RSA (PUBLIC|PRIVATE) KEY-----/
          end

          def openssh?(key)
            key =~ /\Assh-rsa /
          end
        end

      end

    end

  end
end
