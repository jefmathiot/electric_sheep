module ElectricSheep
  module Metadata
    class Encrypted

      def initialize(options, cipher_text)
        @options=options
        @cipher_text = cipher_text
      end

      def decrypt
        Crypto.gpg.string.decrypt(@options.with, @cipher_text)
      end

    end
  end
end
