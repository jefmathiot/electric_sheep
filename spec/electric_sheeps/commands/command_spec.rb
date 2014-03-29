require 'spec_helper'

describe ElectricSheeps::Commands::Command do

  CommandKlazz = Class.new do
    include ElectricSheeps::Commands::Command
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
  end
end
