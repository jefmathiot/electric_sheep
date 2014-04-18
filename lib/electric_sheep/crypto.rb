require 'openssl'
require 'base64'

module ElectricSheep
  module Crypto

    class << self
      def encrypt(plain_text, key_file)
        key = OpenSSL::PKey::RSA.new(read_key_file(key_file))
        raise "Not a public key: #{key_file}" unless key.public?
        Base64.encode64(key.public_encrypt(plain_text))
      end

      def decrypt(cipher_text, key_file)

      end

      private
      def read_key_file(key_file)
        raise "Key file not found #{key_file}" unless File.exists?(key_file)
        key = File.read(key_file)
        return openssh_to_pem(key_file) if openssh?(key)
        return key if pem?(key)
        raise "Key file format not supported" 
      end

      def openssh_to_pem(key_file)
        pem = ""
        IO.popen("ssh-keygen -f #{key_file} -e -m pem").each do|line|
          pem << line
        end
        raise "Unable to convert key file #{key_file} to PEM" unless $?.to_i == 0
        pem
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
