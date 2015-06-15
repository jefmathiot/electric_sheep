module ElectricSheep
  module Metadata
    module CryptoOptions
      extend ActiveSupport::Concern

      included do
        option :with, required: true
      end
    end

    class EncryptOptions < Base
      include CryptoOptions
      # TODO: Validate the provided key is a private key
    end

    class DecryptOptions < Base
      include CryptoOptions
      # TODO: Validate the provided key is a public key
    end
  end
end
