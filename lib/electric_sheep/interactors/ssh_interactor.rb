module ElectricSheep
  module Interactors
    class SshInteractor < Base
      include ShellStat
      include Helpers::ShellSafe

      HOST_KEY_VERIFIERS = { standard: :very, strict: :secure }.freeze

      def initialize(host, job, user, logger = nil)
        super(host, job, logger)
        @user = user
      end

      def exec(*cmd)
        _exec(*cmd) do |cmd_as_string|
          result = session_exec(cmd_as_string)
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
        source = local.expand_path(from.path)
        target = expand_path(to.path)
        copy_paths(source, target, self, from.directory?) do |src, dest|
          scp.upload! src, dest, recursive: from.directory?
        end
      end

      def download!(from, to, local)
        source = expand_path(from.path)
        target = local.expand_path(to.path)
        copy_paths(source, target, local, from.directory?) do |src, dest|
          scp.download! src, dest, recursive: from.directory?
        end
      end

      protected

      def build_session
        Net::SSH.start(@host.hostname, @user, ssh_options)
      end

      def ssh_options
        key_data = PrivateKey.get_key(private_key, :private).export
        { port: @host.ssh_port, keys_only: true, auth_methods: %w(publickey),
          key_data: key_data }.tap do |opts|
          if options.known_hosts
            opts[:user_known_hosts_file] = File.expand_path(options.known_hosts)
          end
          opts[:paranoid] = host_key_checking
        end
      end

      def options
        @job.config.ssh_options
      end

      def host_key_checking
        HOST_KEY_VERIFIERS.fetch(options.host_key_checking&.to_sym, 'standard')
      end

      def private_key
        @host.private_key_data || PrivateKey.from_file(@host.private_key) ||
          @job.private_key_data || PrivateKey.from_file(@job.private_key) ||
          PrivateKey.from_file('~/.ssh/id_rsa')
      end

      def copy_paths(source, target, context, directory, &_)
        if directory
          to_tmpdir(source, target, context) { |path| yield source, path }
        else
          yield source, target
        end
      end

      def to_tmpdir(source, target, context, &_)
        path = tmpdir(source, target)
        File.expand_path(File.join(path, '..')).tap do |parent|
          safe_parent = shell_safe(parent)
          context.exec "mkdir #{safe_parent}"
          yield parent
          context.exec "mv #{shell_safe(path)} #{shell_safe(target)}"
          context.exec "rm -rf #{safe_parent}"
        end
      end

      def tmpdir(source, target)
        File.join(File.dirname(target), Helpers::FSUtil.tempname,
                  File.basename(source))
      end

      def handle_errors(cmd, success, result)
        return if success
        result[:exit_status] = 1
        result[:err] << "Could not execute command #{cmd}"
      end

      def session_exec(cmd)
        result = { out: '', err: '', exit_status: 0 }
        session.open_channel do |channel|
          channel.exec(cmd) do |_, success|
            handle_errors(cmd, success, result)
            Callbacks.attach(channel, result, @logger)
          end
        end
        result
      end

      class Callbacks
        class << self
          def attach(channel, result, logger)
            [:on_data, :on_extended_data, :on_request].each do |method|
              send(method, channel, result, logger)
            end
          end

          def on_data(channel, result, logger)
            channel.on_data do |_, data|
              result[:out] << data
              logger&.debug result[:out]
            end
          end

          def on_extended_data(channel, result, _)
            channel.on_extended_data do |_, _, data|
              result[:err] << data
            end
          end

          def on_request(channel, result, _)
            channel.on_request('exit-status') do |_, data|
              result[:exit_status] = data.read_long
            end
          end
        end
      end

      class PrivateKey
        class << self
          def get_key(key_data, type)
            ::OpenSSL::PKey::RSA.new(convert_to_pem(key_data)).tap do |key|
              raise "Not a #{type} key" unless key.send("#{type}?")
            end
          end

          def from_file(keyfile)
            return unless keyfile.present?
            keyfile = File.expand_path(keyfile)
            raise "Key file not found #{keyfile}" unless File.exist?(keyfile)
            File.read(keyfile)
          end

          private

          def convert_to_pem(key)
            return openssh_to_pem(key) if openssh?(key)
            return key if pem?(key)
            raise 'Key file format not supported'
          end

          def openssh_to_pem(key)
            command = "ssh-keygen -f /dev/stdin -e -m pem <<<$(echo #{key})"
            result = Spawn.exec(command)
            unless (result[:exit_status]).to_i.zero?
              raise "Unable to convert private key to PEM: #{result[:err]}"
            end
            result[:out]
          end

          def pem?(key)
            key =~ /\A-----BEGIN RSA (PUBLIC|PRIVATE) KEY-----/
          end

          def openssh?(key)
            key.start_with?('ssh-rsa')
          end
        end
      end
    end
  end
end
