require 'spec_helper'
require 'fileutils'

describe ElectricSheep::Transports::S3 do
  include Support::Transport

  it {
    defines_options :access_key_id, :secret_key
  }

  let(:s3){ subject.new(project, logger, metadata, hosts) }

  it 'creates an S3 interactor' do
    metadata.expects(:access_key_id).returns('ABCD')
    metadata.expects(:secret_key).returns('secret')
    interactor=s3.remote_interactor
    interactor.must_be_instance_of ElectricSheep::Transports::S3::S3Interactor
  end

  it 'creates an S3 object' do
    project.stubs(:last_product).returns(resource)
    resource.stubs(:basename).returns('file')
    resource.stubs(:extension).returns('.ext')
    resource.stubs(:timestamp?).returns(false)
    metadata.stubs(:to).returns('bucket/path/to')
    resource=s3.remote_resource
    resource.must_be_instance_of ElectricSheep::Resources::S3Object
    resource.bucket.must_equal 'bucket'
    resource.path.must_match /^path\/to\/file-\d{8}-\d{6}\.ext/
  end

  describe ElectricSheep::Transports::S3::S3Interactor do

    let(:interactor){ subject.new('ABCD', 'secret') }

    let(:local_interactor){ mock }

    [:from, :to].each do |m|
      let(m) do
        mock.tap do |resource|
          resource.stubs(:path).returns(m.to_s)
        end
      end
    end

    describe 'disabling test env' do
      before do
        @env=ENV['ELECTRIC_SHEEP_ENV']
        ENV['ELECTRIC_SHEEP_ENV']=nil
      end

      after do
        ENV['ELECTRIC_SHEEP_ENV']=@env
      end

      it 'uses AWS options to build a connection' do
        connection=interactor.send(:connection)
        connection.instance_variable_get(:@aws_access_key_id).must_equal 'ABCD'
        connection.instance_variable_get(:@aws_secret_access_key).
          must_equal 'secret'
      end
    end

    describe 'in the test env' do

      let(:bucket){ 'my-bucket' }

      let(:bucket_path) do
        File.expand_path("#{tmp_directory}/s3/#{bucket}")
      end

      let(:directory_path) do
        "#{bucket_path}/key-prefix"
      end

      let(:tmp_directory) do
        File.expand_path('./tmp')
      end

      let(:working_directory) do
        File.expand_path("#{tmp_directory}/working_dir")
      end

      let(:dummy_content){ 'Do you like your owl ?' }

      def reset_directories(mkdir, *dirs)
        dirs.each do |dir|
          FileUtils.rm_f dir
          FileUtils.mkdir_p dir if mkdir
        end
      end

      before do
        reset_directories true, working_directory, bucket_path
      end

      after do
        #reset_directories false, working_directory, bucket_path
      end

      it 'yields in session' do
        yielded=false
        interactor.in_session do
          yielded=true
        end
        yielded.must_equal true
      end

      def dummy(dir, path)
        File.join(dir, path).tap do |path|
          File.open(path, 'w'){|f| f.write dummy_content }
        end
      end

      def ensure_transfer(action, from_dir, to_dir, local_resource)
        source=dummy(from_dir, from.path)
        local_interactor.expects(:expand_path).with(local_resource.path).
          returns(File.join(to_dir, local_resource.path))
        interactor.send action, from, to, local_interactor
        File.read(File.join(to_dir, to.path)).must_equal dummy_content
      end

      it 'downloads a file from the remote bucket' do
        from.stubs(:bucket).returns(bucket)
        ensure_transfer(:download!, bucket_path, working_directory, to)
      end

      it 'uploads a file to the remote bucket' do
        to.stubs(:bucket).returns(bucket)
        ensure_transfer(:upload!, tmp_directory, bucket_path, from)
      end

      describe 'with a file in the remote bucket' do

        let(:source){ dummy(bucket_path, from.path) }

        before do
          source
          from.stubs(:bucket).returns(bucket)
        end

        it 'removes the file from the remote bucket' do
          interactor.delete!(from)
          File.exists?(source).must_equal false
        end

        it 'stats the remote file' do
          interactor.stat(from).must_equal dummy_content.length
        end

      end

    end

  end

end
