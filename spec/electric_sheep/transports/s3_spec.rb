require 'spec_helper'
require 'fog'

describe ElectricSheep::Transports::S3 do
  include Support::Options

  it {
    defines_options :access_key_id, :secret_key
  }

  let(:bucket_path) do
    './tmp/s3/bucket'
  end

  let(:directory_path) do
    "#{bucket_path}/key-prefix"
  end

  let(:working_directory) do
    './tmp/working_dir'
  end

  before do
    @logger = mock
    @project=ElectricSheep::Metadata::Project.new
    @hosts = ElectricSheep::Metadata::Hosts.new
    @hosts.localhost.working_directory = working_directory
    FileUtils.rm_f working_directory
    FileUtils.rm_f directory_path
    FileUtils.rm_f bucket_path
    FileUtils.mkdir_p directory_path
    FileUtils.mkdir_p working_directory
  end

  def expects_log(operation, direction, to)
    @logger.expects(:info).
      with("#{operation} dummy.file #{direction} #{to} using S3")
  end

  describe 'overriding environment' do
    before do
      @env=ENV['ELECTRIC_SHEEP_ENV']
      ENV['ELECTRIC_SHEEP_ENV']=nil
    end

    after do
      ENV['ELECTRIC_SHEEP_ENV']=@env
    end

    it 'uses AWS options to build a connection' do
      metadata=mock
      metadata.stubs(:access_key_id).returns('XXXX')
      metadata.stubs(:secret_key).returns('SECRET')
      connection=subject.new(nil, nil, metadata, nil).send(:connection)
      connection.instance_variable_get(:@aws_access_key_id).must_equal 'XXXX'
      connection.instance_variable_get(:@aws_secret_access_key).must_equal 'SECRET'
    end
  end

  describe 'transporting a file from localhost to remote bucket' do
    before do
      metadata=ElectricSheep::Metadata::Transport.new(
        to: 'bucket/key-prefix', transport: 's3', access_key_id: 'XXXX', secret_key: 'SECRET'
      )
      @transport=subject.new(@project, @logger, metadata, @hosts)
      @project.start_with! ElectricSheep::Resources::File.new(
        path: './tmp/dummy.file'
      )
      FileUtils.touch './tmp/dummy.file'
    end

    def expects_bucket_object
      File.exists?("#{directory_path}/dummy.file").must_equal true,
        "Expected the remote file to be present"
      @project.last_product.must_be_instance_of ElectricSheep::Resources::S3Object
    end

    it 'makes a copy' do
      expects_log("Copying", "to", "bucket/key-prefix")
      @transport.copy
      # Local file
      File.exists?('./tmp/dummy.file').must_equal true,
        "Expected the source file to be present"
      @project.last_product.must_be_instance_of ElectricSheep::Resources::File
    end

    it 'moves the file' do
      expects_log("Moving", "to", "bucket/key-prefix")
      @transport.move
      expects_bucket_object
      # Local file
      File.exists?('./tmp/dummy.file').must_equal false,
        "Expected the source file to be absent"
    end
  end

  describe 'transporting a file from remote bucket to localhost' do
    before do
      metadata=ElectricSheep::Metadata::Transport.new(
        to: 'localhost', transport: 's3'
      )
      @transport=subject.new(@project, @logger, metadata, @hosts)
      @project.start_with! ElectricSheep::Resources::S3Object.new(
        bucket: 'my-bucket',
        key: 'key-prefix/dummy.file'
      )
      @fog_storage = Fog::Storage.new(
        {
          provider: 'local',
          local_root: './tmp/s3',
          endpoint: 'http://s3.amazonaws.com'
        }
      )
      directory = @fog_storage.directories.new(:key => 'my-bucket')
      directory.files.create(
        key: "key-prefix/dummy.file",
        body: "body",
        multipart_chunk_size: 100.megabytes
      )
    end

    it 'makes a copy' do
      expects_log("Copying", "to", "localhost")
      Fog::Storage.stubs(:new).returns @fog_storage
      @transport.copy
      # Local file
      File.exists?("#{working_directory}/dummy.file").must_equal true,
        "Expected the target file to be present"
      @project.last_product.must_be_instance_of ElectricSheep::Resources::S3Object
    end

    it 'moves the file' do
      expects_log("Moving", "to", "localhost")
      Fog::Storage.stubs(:new).returns @fog_storage
      @transport.move
      # Local file
      File.exists?("#{working_directory}/dummy.file").must_equal true,
        "Expected the target file to be present"
      @project.last_product.must_be_instance_of ElectricSheep::Resources::File
      @fog_storage.directories.get('my-bucket').files.get('key-prefix/dummy.file').must_equal nil,
        "Expected the source file to be absent"
    end
  end
end
