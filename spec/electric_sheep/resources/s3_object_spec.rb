require 'spec_helper'

describe ElectricSheep::Resources::S3Object do
  include Support::Options
  include Support::Files::Named
  include Support::Files::Extended

  it {
    defines_options :directory, :bucket
    requires :bucket
  }

  it 'is remote only' do
    subject.new.local?.must_equal false
  end

  it 'normalize its path' do
    resource=subject.new(path: 'path/to/file.ext')
    resource.extension.must_equal '.ext'
    resource.basename.must_equal 'file'
    resource.parent.must_equal 'path/to'
  end

end
