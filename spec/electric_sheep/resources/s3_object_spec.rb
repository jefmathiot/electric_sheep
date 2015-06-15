require 'spec_helper'

describe ElectricSheep::Resources::S3Object do
  include Support::Options
  include Support::Files::Named
  include Support::Files::Extended

  it do
    defines_options :directory, :bucket, :region
    requires :bucket
  end

  it 'is remote only' do
    subject.new.local?.must_equal false
  end

  it 'normalizes its path' do
    subject.new(path: 'path/to/file.ext').tap do |resource|
      resource.extension.must_equal '.ext'
      resource.basename.must_equal 'file'
      resource.parent.must_equal 'path/to'
    end
  end

  it 'converts to a location' do
    location = subject.new(
      bucket: 'my-bucket',
      directory: 'directory',
      region: 'us-east-1'
    ).to_location
    location.must_be_instance_of ElectricSheep::Metadata::Pipe::Location
    location.id.must_equal 'my-bucket/directory'
    location.location.must_equal 'us-east-1'
    location.type.must_equal :bucket
  end
end
