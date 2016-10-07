require 'spec_helper'

describe ElectricSheep::Command do
  CommandKlazz = Class.new do
    include ElectricSheep::Command
  end

  [:job, :logger, :shell, :resource, :metadata].each do |m|
    let(m) { mock }
  end

  describe CommandKlazz do
    let(:command) do
      subject.new(job, logger, shell, resource, metadata)
    end

    it 'makes initialization options available' do
      command.logger.must_equal logger
      command.input.must_equal resource
      command.shell.must_equal shell
    end

    it 'stats the input and performs' do
      command.expects(:stat!).with(resource)
      command.expects(:perform!).returns(output = mock)
      command.expects(:stat!).with(output)
      command.run!.must_equal output
    end

    # TODO: Move to an agent spec
    it 'extracts options from metadata' do
      metadata.expects(:some_option).returns('VALUE')
      command.send(:option, :some_option).must_equal 'VALUE'
    end

    it 'logs debug message on unknown stat method' do
      resource.stubs(:type).returns('unknown')
      resource.stubs(:stat).returns(mock(size: nil))
      logger.expects(:debug).with(
        regexp_matches(
          /^Unable to stat resource of type unknown: undefined method/
        )
      )
      command.send :stat!, resource
    end

    it 'exposes its shell host' do
      shell.expects(:host).returns(host = mock)
      command.send(:host).must_equal host
    end
  end

  describe ElectricSheep::Command::LoggerSafe do
    it 'obfuscates value' do
      subject.new('value').to_s.must_equal '********'
    end

    it 'provides the raw value' do
      subject.new('value').raw.must_equal 'value'
    end
  end
end
