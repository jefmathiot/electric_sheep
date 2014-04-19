require 'spec_helper'

describe ElectricSheep::Metadata::Encrypted do
  it 'decrypts cipher text' do
    '/path/to/private/key'.tap do |key|
      ElectricSheep::Crypto.expects(:decrypt).with('CIPHER', key).returns('PLAIN')
      subject.new('CIPHER').decrypt(key).must_equal 'PLAIN'
    end
  end
end
