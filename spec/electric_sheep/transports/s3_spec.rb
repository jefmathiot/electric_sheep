require 'spec_helper'
require 'fileutils'

describe ElectricSheep::Transports::S3 do
  include Support::Transport

  it {
    defines_options :access_key_id, :secret_key, :region
  }

  let(:s3){ subject.new(project, logger, hosts, resource, metadata) }


  it 'should have registered as the "s3" transport' do
    ElectricSheep::Agents::Register.transport("s3").must_equal subject
  end

  describe 'creating an S3 interactor' do
    before do
      metadata.expects(:access_key_id).returns('ABCD')
      metadata.expects(:secret_key).returns('secret')
    end

    it 'creates an S3 interactor with the default S3 region' do
      metadata.expects(:region).returns(nil)
      interactor=s3.remote_interactor
      interactor.must_be_instance_of ElectricSheep::Transports::S3::S3Interactor
      # Good enough...
      interactor.instance_variable_get(:@region).must_equal 'us-east-1'
    end

    it 'uses the provided S3 region' do
      metadata.expects(:region).returns('eu-central-1')
      interactor=s3.remote_interactor.instance_variable_get(:@region).
        must_equal 'eu-central-1'
    end

  end

  describe 'creating an S3 object' do

    def ensure_s3_object_created
      resource.stubs(:basename).returns('file')
      resource.stubs(:extension).returns('.ext')
      resource.stubs(:timestamp?).returns(false)
      metadata.stubs(:to).returns('bucket/path/to')
      resource=s3.remote_resource
      resource.must_be_instance_of ElectricSheep::Resources::S3Object
      resource.bucket.must_equal 'bucket'
      resource.path.must_match /^path\/to\/file-\d{8}-\d{6}\.ext/
      resource
    end

    it 'uses the default S3 region' do
      metadata.stubs(:region).returns nil
      ensure_s3_object_created.region.must_equal 'us-east-1'
    end

    it 'uses the provided S3 region' do
      metadata.stubs(:region).returns('eu-central-1')
      ensure_s3_object_created.region.must_equal 'eu-central-1'
    end

  end

  describe ElectricSheep::Transports::S3::S3Interactor do

    let(:interactor){ subject.new('ABCD', 'secret', 'eu-central-1') }

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
        connection.instance_variable_get(:@region).
          must_equal 'eu-central-1'
      end
    end

    describe 'handling multipart upload' do

      let(:source){ mock }

      it 'doesnt split files up to 10 MB' do
        source.stubs(:size).returns(10.megabytes)
        interactor.send(:upload_options, source)[:multipart_chunk_size].
          must_be_nil
      end

      it 'split files beyond 10 MB' do
        source.stubs(:size).returns(10.megabytes + 1)
        interactor.send(:upload_options, source)[:multipart_chunk_size].
        must_equal 5.megabytes
      end

      it 'selects the smallest chunk size available' do
        source.stubs(:size).returns(5.megabytes * 10001)
        interactor.send(:upload_options, source)[:multipart_chunk_size].
          must_equal 10.megabytes
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
        reset_directories false, working_directory, bucket_path
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

      def ensure_transfer(action, from_dir, to_dir, expanded_dir,
        local_resource)
        source=dummy(from_dir, from.path)
        local_interactor.expects(:expand_path).with(local_resource.path).
          returns(File.join(expanded_dir, local_resource.path))
        interactor.send action, from, to, local_interactor
        File.read(File.join(to_dir, to.path)).must_equal dummy_content
      end

      it 'downloads a file from the remote bucket' do
        from.stubs(:bucket).returns(bucket)
        ensure_transfer(:download!, bucket_path, working_directory,
          working_directory, to)
      end

      it 'uploads a file to the remote bucket' do
        to.stubs(:bucket).returns(bucket)
        ensure_transfer(:upload!, tmp_directory, bucket_path, tmp_directory,
          from)
      end

      it 'uses the upload options' do
        "#{working_directory}/dummy.file".tap do |path|
          local_interactor.stubs(:expand_path).returns(path)
          FileUtils.touch(path)
        end
        interactor.expects(:remote_files).with(to).returns(files=mock)
        interactor.expects(:upload_options).with(kind_of(File)).
          returns(an_option: 'a_value')
        files.expects(:create).with(has_entry(:an_option, 'a_value'))
        interactor.upload!(from, to, local_interactor)
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
          file = {"Content-Length" => 22}
          interactor.expects(:remote_files).with(from).returns(files=mock)
          files.expects(:head).returns(file)
          interactor.stat(from).must_equal dummy_content.length
        end

      end

    end

  end

end
