require 'spec_helper'

describe ElectricSheeps::Commands::Compression::TarGz do

  before do
    @project, @logger, @shell = ElectricSheeps::Metadata::Project.new, mock, mock

    @command = subject.new(
      'step-id', @project, @logger, @shell, '/tmp',
      file: ElectricSheeps::Resources::File.new(path: '/tmp/some-file.txt'),
      directory: ElectricSheeps::Resources::Directory.new(path: '/tmp/some-directory')
    )
    @shell.expects(:remote?).returns(true)
    @seq = sequence('command')
  end
  
  def assert_product(file)
    product = @project.product_of('step-id')
    product.wont_be_nil
    product.path.must_equal "/tmp/#{file}.tar.gz"
    product.remote?.must_equal true
  end

  it 'compresses the provided file' do
    @logger.expects(:info).in_sequence(@seq).
      with 'Compressing /tmp/some-file.txt to some-file.txt.tar.gz'
    @shell.expects(:exec).with('tar -cvzf "/tmp/some-file.txt.tar.gz" "/tmp/some-file.txt"')
    @command.perform
    assert_product('some-file.txt')
  end

  it 'compresses the provided directory' do
    @command.instance_variable_set :@file, nil
    @logger.expects(:info).in_sequence(@seq).
      with 'Compressing /tmp/some-directory to some-directory.tar.gz'
    @shell.expects(:exec).with('tar -cvzf "/tmp/some-directory.tar.gz" "/tmp/some-directory"')
    @command.perform
    assert_product('some-directory')
  end

end
