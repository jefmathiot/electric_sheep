require 'spec_helper'

describe ElectricSheep::Resources::FileSystem do
  include Support::Options

  it{
    defines_options :path, :host
    requires :path
  }

  it 'defaults to local' do
    subject.new.remote?.must_equal false
    subject.new.local?.must_equal true
  end

  it 'is local when localhost' do
    subject.new(host: ElectricSheep::Metadata::Localhost.new).local?.must_equal true
  end

  it 'is remote when not localhost' do
    subject.new(host: ElectricSheep::Metadata::Host.new).remote?.must_equal true
  end

  it 'extracts the basename' do
    subject.new(path: '/tmp/some-file.txt').basename.must_equal 'some-file.txt'
  end

end
