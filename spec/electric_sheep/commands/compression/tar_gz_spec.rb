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
      @project, @logger, @shell = ElectricSheep::Metadata::Project.new, mock, mock

      @command = subject.new(@project, @logger, @shell, '/tmp', mock)
      @seq = sequence('command')
    end
    
    def assert_product(file)
      product = @project.last_product
      product.wont_be_nil
      product.path.must_equal "/tmp/#{file}.tar.gz"
    end

    it 'compresses the provided file' do
      @project.start_with!(file('/tmp/some-file.txt'))
      @logger.expects(:info).in_sequence(@seq).
        with 'Compressing /tmp/some-file.txt to some-file.txt.tar.gz'
      @shell.expects(:exec).
        with('tar -cvzf "/tmp/some-file.txt.tar.gz" "/tmp/some-file.txt" &> /dev/null')
      @shell.expects(:file_resource).
        with(path: '/tmp/some-file.txt.tar.gz').
        returns(file('/tmp/some-file.txt.tar.gz'))
      @command.perform
      assert_product('some-file.txt')
    end

    it 'compresses the provided directory' do
      @project.start_with!(directory('/tmp/some-directory'))
      @logger.expects(:info).in_sequence(@seq).
        with 'Compressing /tmp/some-directory to some-directory.tar.gz'
      @shell.expects(:exec).
        with('tar -cvzf "/tmp/some-directory.tar.gz" "/tmp/some-directory" &> /dev/null')
      @shell.expects(:file_resource).
        with(path: '/tmp/some-directory.tar.gz').
        returns(file('/tmp/some-directory.tar.gz'))
      @command.perform
      assert_product('some-directory')
    end

  end

end
