require 'openssl'
require 'base64'

module ElectricSheep
  module Crypto

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
        OpenSSL::PKey::RSA.new(read_key_file(key_file)).tap do |key|
          raise "Not a #{type} key: #{key_file}" unless key.send("#{type}?")
        end
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
        result = ""
        ::Session::Sh.new do |session|
          session.execute("ssh-keygen -f #{key_file} -e -m pem") do |out, err|
            result << out
          end
          raise "Unable to convert key file #{key_file} to PEM" unless session.exit_status == 0
        end
        result
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
