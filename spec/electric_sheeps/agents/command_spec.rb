require 'spec_helper'

describe ElectricSheeps::Agents::Command do

  CommandKlazz = Class.new do
    include ElectricSheeps::Agents::Command
  end

  class FreshAir
    include ElectricSheeps::Resources::Resource
  end

  describe CommandKlazz do
    it 'makes options available' do
      agent = subject.new(logger: logger = mock, shell: shell = mock, work_dir: '/tmp')
      agent.logger.must_equal logger
      agent.shell.must_equal shell
      agent.work_dir.must_equal '/tmp'
    end
  end
end
