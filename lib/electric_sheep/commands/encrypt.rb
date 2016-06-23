module ElectricSheep
  module Commands
    class Encrypt
      include Command
      include Helpers::ShellSafe
      include DeleteSource

      register as: 'encrypt'

      option :public_key, required: true

      def perform!
        logger.info "Encrypting \"#{input.basename}\""
        file_resource(host, extension: '.gpg').tap do |output|
          copy_key do |keyfile|
            encrypt(input, output, keyfile)
          end
        end
      end

      private

      def encrypt(input, output, keyfile)
        input_path = shell.expand_path(input.path)
        output_path = shell.expand_path(output.path)
        Crypto.gpg.file(shell).encrypt(keyfile, input_path, output_path)
        delete_source!(input_path)
      end

      def key_contents
        local_key = shell_safe(option(:public_key))
        cmd = Spawn.exec("gpg --batch --enarmor < \"#{local_key}\"")
        if cmd[:exit_status] != 0
          raise 'Unable to convert the public key to the ASCII-armored format'
        end
        cmd[:out]
      end

      def copy_key(&_)
        Helpers::FSUtil.tempfile(shell) do |keyfile|
          Helpers::FSUtil.tempfile(shell) do |ascii|
            shell.exec "echo \"#{key_contents}\" > #{ascii}"
            shell.exec "gpg --batch --dearmor < #{ascii} > #{keyfile}"
          end
          yield keyfile
        end
      end
    end
  end
end
