require 'spec_helper'

describe ElectricSheep::Commands::S3::S3cmd do
  include Support::Command

  it{
    defines_options :access_key, :secret_key
    requires :access_key, :secret_key
  }

  it 'should have registered as the "s3cmd" agent of type command' do
    ElectricSheep::Agents::Register.command('s3cmd').must_equal subject
  end

  before do
    @project, @logger, @shell, @metadata = ElectricSheep::Metadata::Project.new, mock, mock, mock
    @project.start_with! ElectricSheep::Resources::File.new(path: '/tmp/the-file')
    @metadata.stubs(:bucket).returns('the-bucket')
    @metadata.stubs(:access_key).returns('ACCESSKEY')
    @metadata.stubs(:secret_key).returns('SECRET')
  end

  it 'puts the file to the remote bucket' do
    s3cmd = subject.new(@project, @logger, @shell, '/tmp/', @metadata)

    seq = sequence('cmd')
    @logger.expects(:info).with(%{Uploading file "the-file" to S3 bucket "the-bucket"})
    @shell.expects(:exec).with %{s3cmd put "/tmp/the-file" "s3://the-bucket" } <<
      %{--access_key="ACCESSKEY" --secret_key="SECRET"}
    s3cmd.perform

    @project.last_product.tap do |product|
      product.must_be_instance_of ElectricSheep::Resources::S3Object
      product.bucket.must_equal 'the-bucket'
      product.key.must_equal 'the-file'
      product.access_key.must_equal 'ACCESSKEY'
      product.secret_key.must_equal 'SECRET'
    end
  end
end
