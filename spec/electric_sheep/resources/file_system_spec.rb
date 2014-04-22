require 'spec_helper'

describe ElectricSheep::Resources::FileSystem do
  include Support::Properties

  it{
    defines_properties :path, :remote
    requires :path
  }

  it 'defaults remote to false' do
    subject.new.remote?.must_equal false
  end

  it 'defines a remote option' do
    subject.new(remote: true).remote?.must_equal true
  end

  it 'extracts the basename' do
    subject.new(path: '/tmp/some-file.txt').basename.must_equal 'some-file.txt'
  end

end
