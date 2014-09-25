require 'spec_helper'

describe ElectricSheep::Transport do
  TransportKlazz = Class.new do
    include ElectricSheep::Transport

    attr_reader :done

    def do
      @done = true
    end
  end

  describe TransportKlazz do
    it 'performs using transport type from metadata' do
      transport=subject.new(
        project=ElectricSheep::Metadata::Project.new(id: 'some-project'),
        logger=mock,
        metadata=mock,
        hosts=ElectricSheep::Metadata::Hosts.new
      )
      ElectricSheep::Helpers::Directories.any_instance.expects(:mk_project_directory!)
      metadata.expects(:type).returns(:do)
      transport.perform
      transport.done.must_equal true
    end
  end
end
