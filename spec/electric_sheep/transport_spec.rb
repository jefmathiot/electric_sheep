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
    before do
      @transport = subject.new(
        @project=ElectricSheep::Metadata::Project.new(id: 'some-project'),
        @logger=mock,
        @metadata=mock,
        @hosts=ElectricSheep::Metadata::Hosts.new
      )
    end

    it 'performs using transport type from metadata' do
      ElectricSheep::Helpers::Directories.any_instance.expects(:mk_project_directory!)
      @metadata.expects(:type).returns(:do)
      @transport.run!
      @transport.done.must_equal true
    end

    describe 'log' do
      before do
        @transport.expects(:input).returns(@input=mock)
        @input.expects(:name).returns('file.name')
        @transport.expects(:option).with(:to).returns('destination')
        @transport.expects(:option).with(:transport).returns('scp')
      end
      it 'log copy operation' do
        @logger.expects(:info).with("Copying file.name to destination using scp")
        @transport.send(:log, :copy)
      end

      it 'log move operation' do
        @logger.expects(:info).with("Moving file.name to destination using scp")
        @transport.send(:log, :move)
      end
    end
  end

end
