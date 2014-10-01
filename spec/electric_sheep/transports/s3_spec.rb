require 'spec_helper'

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

  before do
    @logger, @project=mock
    @project=ElectricSheep::Metadata::Project.new(
      working_directory: working_directory='./tmp/working_dir'
    )
    FileUtils.rm_f working_directory
    FileUtils.rm_f bucket_path
    FileUtils.mkdir_p directory_path
  end

  def expects_log(operation, direction)
    @logger.expects(:info).
      with("#{operation} dummy.file #{direction} bucket/key-prefix using S3")
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
        to: 'bucket/key-prefix', transport: 's3'
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
      expects_log("Copying", "to")
      @transport.copy
      # Local file
      File.exists?('./tmp/dummy.file').must_equal true,
        "Expected the source file to be present"
      @project.last_product.must_be_instance_of ElectricSheep::Resources::File
    end

    it 'moves the file' do
      expects_log("Moving", "to")
      @transport.move
      expects_bucket_object
      # Local file
      File.exists?('./tmp/dummy.file').must_equal false,
        "Expected the source file to be absent"
    end
  end
end
