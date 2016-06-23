require 'spec_helper'

describe ElectricSheep::Resources::FileSystem do
  include Support::Options
  include Support::Files::Named
  include Support::Hosted

  it 'defaults to local' do
    subject.new.remote?.must_equal false
    subject.new.local?.must_equal true
  end

  it 'is local when localhost' do
    subject.new(host: ElectricSheep::Metadata::Localhost.new)
           .local?.must_equal true
  end

  it 'is remote when not localhost' do
    subject.new(host: ElectricSheep::Metadata::Host.new).remote?.must_equal true
  end
end
