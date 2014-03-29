require 'spec_helper'

describe ElectricSheeps::Commands::Command do

  CommandKlazz = Class.new do
    include ElectricSheeps::Commands::Command
    prerequisite :check
  end

  CommandKlazz2 = Class.new do
    include ElectricSheeps::Commands::Command
    prerequisite :check

    def check
    end
  end

  class FreshAir
    include ElectricSheeps::Resources::Resource
  end

  describe CommandKlazz do
    it 'makes options available' do
      agent = subject.new(logger = mock, shell = mock, '/tmp', nil)
      agent.logger.must_equal logger
      agent.shell.must_equal shell
      agent.work_dir.must_equal '/tmp'
    end

    it 'detect if a prerequisite is not defined' do
      agent = subject.new(logger = mock, shell = mock, '/tmp', nil)
      -> { agent.check_prerequisites }.must_raise Exception
    end
  end

  describe CommandKlazz2 do
    it 'detect if a prerequisite is defined' do
      agent = subject.new(logger = mock, shell = mock, '/tmp', nil)
      agent.check_prerequisites
    end
  end

end
