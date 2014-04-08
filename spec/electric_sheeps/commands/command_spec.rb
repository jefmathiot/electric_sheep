require 'spec_helper'

describe ElectricSheeps::Commands::Command do

  CommandKlazz = Class.new do
    include ElectricSheeps::Commands::Command
    prerequisite :check_something
  end

  CommandKlazz2 = Class.new do
    include ElectricSheeps::Commands::Command
    prerequisite :check_something

    def check_something
    end

  end

  class FreshAir
    include ElectricSheeps::Resources::Resource
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

  end

  describe CommandKlazz2 do

    it 'does not raise when all prerequisites are defined' do
      command = subject.new(mock, mock, mock, '/tmp', mock)
      command.check_prerequisites
    end

  end

end
