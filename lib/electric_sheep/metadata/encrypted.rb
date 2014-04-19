module ElectricSheep
  module Metadata
    class Encrypted
      def initialize(cipher_text)
        @cipher_text = cipher_text
      end

      def decrypt(key_file)
        Crypto.decrypt(@cipher_text, key_file)
      end
    end
  end
end
