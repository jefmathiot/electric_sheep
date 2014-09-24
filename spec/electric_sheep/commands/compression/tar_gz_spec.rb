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
      @shell.expects(:project_directory).returns('/project/dir')
      @shell.expects(:host).returns(@host)
      @shell.expects(:mk_project_directory!)
      @command = subject.new(@project, @logger, @shell, @metadata=mock)
      @seq = sequence('command')
    end

    def assert_product(file)
      product = @project.last_product
      product.wont_be_nil
      product.path.must_equal "/project/dir/#{file}.tar.gz"
    end

    def self.describe_compression(input_type, delete_source=false)
      it "compresses the provided #{input_type} (delete source: #{delete_source})" do
        input="/tmp/some-#{input_type}"
        output="/project/dir/some-#{input_type}.tar.gz"
        @metadata.expects(:delete_source).returns(delete_source)
        @project.start_with!(send(input_type, input))
        @logger.expects(:info).in_sequence(@seq).
          with "Compressing #{input} to #{File.basename(output)}"
        @shell.expects(:exec).in_sequence(@seq).
          with("tar -cvzf \"#{output}\" \"#{input}\" &> /dev/null")
        if delete_source
          @shell.expects(:expand_path).with(input).returns(input)
          @shell.expects(:exec).in_sequence(@seq).
            with("rm -f \"#{input}\"")
        end
        @shell.expects(:file_resource).in_sequence(@seq).
          with(@host, output).
          returns(send(input_type, output))
        @command.perform
        assert_product("some-#{input_type}")
      end
    end

    describe_compression :file
    describe_compression :directory
    describe_compression :file, true
    describe_compression :directory, true

  end

end
