require 'spec_helper'
describe ElectricSheep::Commands::Compression::TarGz do
  include Support::Command

  it{
    defines_options :delete_source
  }

  it 'should have registered as "tar_gz"' do
    ElectricSheep::Agents::Register.command("tar_gz").must_equal subject
  end

  describe "executing the command" do

    before do
      @project, @logger, @shell, @host = ElectricSheep::Metadata::Project.new,
        mock, mock, mock
      @shell.expects(:host).returns(@host)
      @command = subject.new(@project, @logger, @shell, @metadata=mock)
      @seq = sequence('command')
      Timecop.travel Time.utc(2014, 6, 5, 4, 3, 2)
    end

    after do
      Timecop.return
    end

    def assert_product(file)
      product = @project.last_product
      product.wont_be_nil
      product.path.must_equal "#{file}-20140605-040302.tar.gz"
    end

    def self.describe_compression(input_type, delete_source=false)
      it "compresses the provided #{input_type} (delete source: #{delete_source})" do
        input="/tmp/some-#{input_type}"
        output="/project/dir/some-#{input_type}.tar.gz"
        @shell.expects(:expand_path).with("some-#{input_type}-20140605-040302.tar.gz").
          returns(output)
        @shell.expects(:expand_path).with(input).
          returns(input)
        @metadata.expects(:delete_source).returns(delete_source)
        @project.start_with!(send(input_type, input))
        @logger.expects(:info).in_sequence(@seq).
          with "Compressing #{input} to some-#{input_type}.tar.gz"
        @shell.expects(:exec).in_sequence(@seq).
          with("cd #{File.dirname(input)}; " +
            "tar -cvzf #{output} #{File.basename(input)} 1>&2")
        if delete_source
          @shell.expects(:exec).in_sequence(@seq).
            with("rm -rf #{input}")
        end
        @command.run!
        assert_product("some-#{input_type}")
      end
    end

    describe_compression :file
    describe_compression :directory
    describe_compression :file, true
    describe_compression :directory, true

  end

end
