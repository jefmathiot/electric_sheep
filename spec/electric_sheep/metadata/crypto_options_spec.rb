require 'spec_helper'

describe ElectricSheep::Metadata::CryptoOptions do
  include Support::Options

  CryptoOptionsKlazz = Class.new(ElectricSheep::Metadata::Base) do
    include ElectricSheep::Metadata::CryptoOptions
  end

  describe CryptoOptionsKlazz do
    it do
      defines_options :with
      requires :with
    end
  end
end

describe ElectricSheep::Metadata::EncryptOptions do
end

describe ElectricSheep::Metadata::DecryptOptions do
end
