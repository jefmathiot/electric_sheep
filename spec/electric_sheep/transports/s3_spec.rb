require 'spec_helper'
require 'fog'

describe ElectricSheep::Transports::S3 do
  include Support::Options

  it {
    defines_options :access_key_id, :secret_key
  }

  let(:bucket_path) do
    './tmp/s3/my-bucket'
  end

  let(:directory_path) do
    "#{bucket_path}/key-prefix"
  end

  let(:working_directory) do
    './tmp/working_dir'
  end

  before do
    @logger = mock
    @project=ElectricSheep::Metadata::Project.new(id: "s3")
    @hosts = ElectricSheep::Metadata::Hosts.new
    @hosts.localhost.working_directory = working_directory
    FileUtils.rm_f working_directory
    FileUtils.mkdir_p working_directory
    FileUtils.rm_rf bucket_path
    FileUtils.mkdir_p directory_path
    Timecop.travel(Time.utc(2014, 1, 1, 0, 0, 0))
  end

  after do
    Timecop.return
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

  describe 'transporting a file from the localhost to a remote bucket' do
    before do
      metadata=ElectricSheep::Metadata::Transport.new(
        to: 'my-bucket/key-prefix', transport: 's3', access_key_id: 'XXXX', secret_key: 'SECRET'
      )
      @transport = subject.new(@project, @logger, metadata, @hosts)
      @project.start_with! resource=ElectricSheep::Resources::File.new(
        path: File.expand_path('./tmp/dummy.file')
      )
      @logger.stubs(:debug)
      @transport.send(:local_interactor).in_session
      FileUtils.touch './tmp/dummy.file'
    end

    def expects_bucket_object(type)
      File.exists?("#{directory_path}/dummy-20140101-000000.file").must_equal true,
        "Expected the remote file to be present"
      @project.last_product.must_be_instance_of type
    end

    it 'makes a copy' do
      @transport.expects(:log).with(:copy)
      @transport.copy
      expects_bucket_object(ElectricSheep::Resources::File)
      # Local file
      File.exists?('./tmp/dummy.file').must_equal true,
        "Expected the source file to be present"
    end

    it 'moves the file' do
      @transport.expects(:log).with(:move)
      @transport.move
      expects_bucket_object(ElectricSheep::Resources::S3Object)
      # Local file
      File.exists?('./tmp/dummy.file').must_equal false,
        "Expected the source file to be absent"
    end
  end

  describe 'transporting a file from a remote bucket to the localhost' do
    before do
      metadata=ElectricSheep::Metadata::Transport.new(
        to: 'localhost', transport: 's3'
      )
      @transport = subject.new(@project, @logger, metadata, @hosts)
      @project.start_with! resource=ElectricSheep::Resources::S3Object.new(
        bucket: 'my-bucket',
        path: 'key-prefix/dummy.file'
      )
      @logger.stubs(:debug)
      @transport.send(:local_interactor).in_session
      FileUtils.touch "#{directory_path}/dummy.file"
    end

    it 'makes a copy' do
      @transport.expects(:log).with(:copy)
      @transport.copy
      # Local file
      File.exists?("#{working_directory}/#{@project.id}/dummy-20140101-000000.file").must_equal true,
        "Expected the target file to be present"
      @project.last_product.must_be_instance_of ElectricSheep::Resources::S3Object
    end

    it 'moves the file' do
      @transport.expects(:log).with(:move)
      @transport.move
      # Local file
      File.exists?("#{working_directory}/#{@project.id}/dummy-20140101-000000.file").must_equal true,
        "Expected the target file to be present"
      File.exists?("#{directory_path}/dummy.file").must_equal false,
        "Expected the source file to be absent"
      @project.last_product.must_be_instance_of ElectricSheep::Resources::File
    end
  end
end
