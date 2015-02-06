require 'spec_helper'

describe ElectricSheep::Metadata::Encrypted do
  it 'decrypts cipher text' do
    ElectricSheep::Crypto.gpg.expects(:string).returns(encryptor=mock)
    '/path/to/private/key'.tap do |key|
      encryptor.expects(:decrypt).with(key, 'CIPHER').returns('PLAIN')
      decrypt_options = mock(with: key)
      subject.new(decrypt_options, 'CIPHER').decrypt(key).must_equal 'PLAIN'
    end
  end
end
