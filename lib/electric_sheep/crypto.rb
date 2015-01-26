require 'openssl'
require 'base64'

module ElectricSheep
  module Crypto

    class << self

      def open_ssl
        OpenSSL
      end

    end

    class OpenSSL

      class << self

        def encrypt(plain_text, key_file)
          key = get_key(key_file, :public)
          Base64.encode64(key.public_encrypt(plain_text)).gsub(/\n/, '')
        end

        def decrypt(cipher_text, key_file)
          key = get_key(key_file, :private)
          key.private_decrypt(Base64.decode64(cipher_text))
        end

        def get_key(key_file, type)
          ::OpenSSL::PKey::RSA.new(read_key_file(key_file)).tap do |key|
            raise "Not a #{type} key: #{key_file}" unless key.send("#{type}?")
          end
        end

        private
        def read_key_file(key_file)
          key_file=File.expand_path(key_file)
          raise "Key file not found #{key_file}" unless File.exists?(key_file)
          key = File.read(key_file)
          return openssh_to_pem(key_file) if openssh?(key)
          return key if pem?(key)
          raise "Key file format not supported"
        end

        def openssh_to_pem(key_file)
          result = Spawn.exec("ssh-keygen -f #{key_file} -e -m pem")
          unless result[:exit_status] == 0
            raise "Unable to convert key file #{key_file} to PEM: " +
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
