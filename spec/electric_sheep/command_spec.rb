require 'spec_helper'

describe ElectricSheep::Command do

  CommandKlazz = Class.new do
    include ElectricSheep::Command
    prerequisite :check_something
  end

  CommandKlazz2 = Class.new do
    include ElectricSheep::Command
    prerequisite :check_something

    def check_something
    end

  end

  class FreshAir < ElectricSheep::Resources::Resource
  end

  before do
    @shell = mock
    @shell.expects(:mk_project_directory!)
  end

  describe CommandKlazz do
    it 'makes initialization options available' do
      command = subject.new(mock, logger = mock, @shell, mock)
      command.logger.must_equal logger
      command.shell.must_equal @shell
    end

    it 'raises an exceptions if a prerequisite is not defined' do
      command = subject.new(mock, mock, @shell, mock)
      -> { command.check_prerequisites }.must_raise RuntimeError,
        "Missing check in CommandKlazz"
    end

    it 'stores the command product' do
      command = subject.new(project = mock, mock, @shell, mock)
      project.expects(:store_product!).with(resource = mock)
      command.send :done!, resource
    end

    it 'uses the previous product as the resource' do
      command = subject.new(project = mock, mock, @shell, mock)
      project.expects(:last_product).returns(resource = mock)
      command.send(:resource).must_equal resource
    end

    it 'extracts options from metadata' do
      command = subject.new(mock, mock, @shell, metadata = mock)
      metadata.expects(:some_option).returns('VALUE')
      command.send(:option, :some_option).must_equal 'VALUE'
    end

    it 'decrypts options' do
      command = subject.new(project = mock, mock, @shell, metadata = mock)
      metadata.expects(:some_option).returns(encrypted = mock)
      project.expects(:private_key).returns('/path/to/private/key')
      encrypted.expects(:decrypt).with('/path/to/private/key').returns('VALUE')
      command.send(:option, :some_option).must_equal 'VALUE'
    end

  end

  describe CommandKlazz2 do

    it 'does not raise when all prerequisites are defined' do
      command = subject.new(mock, mock, @shell, mock)
      command.check_prerequisites
    end

  end

end
