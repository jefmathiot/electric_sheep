require 'spec_helper'

describe ElectricSheep::Commands::Command do

  CommandKlazz = Class.new do
    include ElectricSheep::Commands::Command
    prerequisite :check_something
  end

  CommandKlazz2 = Class.new do
    include ElectricSheep::Commands::Command
    prerequisite :check_something

    def check_something
    end

  end

  class FreshAir < ElectricSheep::Resources::Resource
  end

  describe CommandKlazz do

    it 'makes initialization options available' do
      command = subject.new(mock, logger = mock, shell = mock, '/tmp', mock)
      command.logger.must_equal logger
      command.shell.must_equal shell
      command.work_dir.must_equal '/tmp'
    end

    it 'raises an exceptions if a prerequisite is not defined' do
      command = subject.new(mock, mock, mock, '/tmp', mock)
      -> { command.check_prerequisites }.must_raise RuntimeError,
        "Missing check in CommandKlazz"
    end

    it 'stores the command product' do
      command = subject.new(project = mock, mock, mock, '/tmp', mock)
      project.expects(:store_product!).with(resource = mock)
      command.send :done!, resource
    end

    it 'uses the previous product as the resource' do
      command = subject.new(project = mock, mock, mock, '/tmp', mock)
      project.expects(:last_product).returns(resource = mock)
      command.send(:resource).must_equal resource
    end

    it 'extracts options from metadata' do
      command = subject.new(mock, mock, mock, '/tmp', metadata = mock)
      metadata.expects(:some_option).returns('VALUE')
      command.send(:option, :some_option).must_equal 'VALUE'
    end

    it 'decrypts options' do
      command = subject.new(project = mock, mock, mock, '/tmp', metadata = mock)
      metadata.expects(:some_option).returns(encrypted = mock)
      project.expects(:private_key).returns('/path/to/private/key')
      encrypted.expects(:decrypt).with('/path/to/private/key').returns('VALUE')
      command.send(:option, :some_option).must_equal 'VALUE'
    end

  end

  describe CommandKlazz2 do

    it 'does not raise when all prerequisites are defined' do
      command = subject.new(mock, mock, mock, '/tmp', mock)
      command.check_prerequisites
    end

  end

end
