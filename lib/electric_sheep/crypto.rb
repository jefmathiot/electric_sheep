require 'openssl'
require 'base64'
require 'fileutils'

module ElectricSheep
  module Crypto
    class << self
      def gpg
        GPG
      end
    end

    module GPG
      module Encryptor
        include Helpers::ShellSafe

        BASE_COMMAND = 'gpg --batch'.freeze

        def initialize(executor)
          @executor = executor
        end

        private

        def exec(cmd)
          result = @executor.exec cmd
          if result[:exit_status] != 0
            fail "Command failed to complete \"#{cmd}\": #{result[:err]}"
          end
          result[:out]
        end

        def keyid(keyfile)
          keylist = exec "#{BASE_COMMAND} --with-colons --fixed-list-mode " \
                         "--keyid-format 0xlong #{keyfile}"
          keylist.split(/\n+/).each do |line|
            return line.split(':')[4] if line =~ /^(pub|sec):/
          end
          fail "Unable to retrieve key info for #{keyfile}"
        end

        def with_keyring(keyfile, &_)
          output = nil
          # Using the block form to ensure the directory will be removed
          Helpers::FSUtil.tempdir(@executor) do |homedir|
            cmd = "#{BASE_COMMAND} --homedir #{homedir}"
            import_key(cmd, keyfile)
            output = yield cmd
          end
          output
        end

        def import_key(cmd, keyfile)
          exec "#{cmd} --import #{keyfile}"
        end

        def expand_path(path)
          Helpers::FSUtil.expand_path(@executor, path)
        end

        def with_content_file(text, &_)
          # Using the block form to ensure the file will be removed
          Helpers::FSUtil.tempfile(@executor) do |path|
            exec "echo #{shell_safe(text)} > #{path} && " \
                 "chmod 0700 #{path}"
            yield path
          end
        end

        def command_options(action, keyfile)
          " --no-version --#{action} --always-trust -r #{keyid(keyfile)}"
        end

        def ascii_armor(options)
          options[:ascii] == true ? ' --armor' : ''
        end

        def wrap(action, keyfile, source, output = nil, &_)
          with_keyring(keyfile) do |cmd|
            cmd << yield if block_given?
            cmd << command_options(action, keyfile)
            wrapper = "cat #{source} | #{cmd}"
            wrapper << " > #{output}" if output
            exec wrapper
          end
        end
      end

      class FileEncryptor
        include Encryptor

        def encrypt(keyfile, source, output, options = {})
          perform(:encrypt, keyfile, source, output) do
            ascii_armor(options)
          end
        end

        def decrypt(keyfile, source, output, _options = {})
          perform(:decrypt, keyfile, source, output)
        end

        private

        def perform(action, keyfile, source, output, &block)
          keyfile = expand_path(keyfile)
          source = expand_path(source)
          expand_path(output).tap do |path|
            wrap(action, keyfile, source, path, &block)
          end
        end
      end

      class StringEncryptor
        include Encryptor

        PGP_ARMOR_HEADER = '-----BEGIN PGP MESSAGE-----'.freeze
        PGP_ARMOR_FOOTER = '-----END PGP MESSAGE-----'.freeze

        def encrypt(keyfile, plain_text, options = {})
          output = perform(:encrypt, keyfile, plain_text) do
            ascii_armor(options)
          end
          options[:compact] ? compact(output) : output
        end

        def decrypt(keyfile, cipher_text, _options = {})
          cipher_text = expand(cipher_text)
          perform(:decrypt, keyfile, cipher_text)
        end

        def perform(action, keyfile, input, &block)
          keyfile = expand_path(keyfile)
          output = nil
          with_content_file(input) do |source|
            output = wrap(action, keyfile, source, nil, &block)
          end
          output
        end

        private

        def expand(cipher_text)
          return cipher_text if cipher_text =~ /^#{PGP_ARMOR_HEADER}/
          "#{PGP_ARMOR_HEADER}\n\n#{cipher_text}\n#{PGP_ARMOR_FOOTER}"
        end

        def compact(cipher_text)
          return cipher_text unless cipher_text =~ /^#{PGP_ARMOR_HEADER}/
          cipher_text.gsub(/-----(BEGIN|END) PGP MESSAGE-----/, '')
            .split(/\n+/).join
        end
      end

      class << self
        def file(executor)
          FileEncryptor.new(executor)
        end

        def string(executor)
          StringEncryptor.new(executor)
        end
      end
    end
  end
end
