require 'spec_helper'

describe ElectricSheeps::Commands::S3::S3cmd do

  it 'should have registered as the "s3cmd" agent of type command' do
    ElectricSheeps::Commands::Register.command('s3cmd').must_equal subject
  end

  it 'expects s3bucket and file resources' do
    s3cmd = subject.new('s3-step', nil, nil, nil, nil,
      file: ElectricSheeps::Resources::File.new(path: 'somefile.txt'),
      s3_bucket: ElectricSheeps::Resources::S3Bucket.new(
        url: 'some_url',
        access_key: 'some_access_key',
        secret_key: 'some_secret_key'
      )
    )

    s3cmd.s3_bucket.url.must_equal 'some_url'
    s3cmd.s3_bucket.access_key.must_equal 'some_access_key'
    s3cmd.s3_bucket.secret_key.must_equal 'some_secret_key'
    s3cmd.file.path.must_equal 'somefile.txt'
  end
end
