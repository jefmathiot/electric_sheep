require 'spec_helper'

describe ElectricSheep::Transport do
  TransportKlazz = Class.new do
    include ElectricSheep::Transport

    attr_reader :project, :logger, :metadata, :hosts, :done

    def do
      @done = true
    end
  end

  describe TransportKlazz do
    it 'performs using transport type from metadata' do
      transport=subject.new(project=mock, logger=mock, metadata=mock, hosts=mock,shell=mock)
      metadata.expects(:type).returns(:do)
      transport.perform

      transport.project.must_equal project
      transport.logger.must_equal logger
      transport.metadata.must_equal metadata
      transport.hosts.must_equal hosts
      transport.done.must_equal true
    end
  end
end
