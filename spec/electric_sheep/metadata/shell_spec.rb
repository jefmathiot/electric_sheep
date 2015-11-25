require 'spec_helper'

describe ElectricSheep::Metadata::Shell do
  include Support::ShellMetadata
  include Support::Options
  include Support::Queue

  def queue_items
    ([0] * 2).map do
      ElectricSheep::Metadata::Command.new(config)
    end
  end

  describe 'validating' do
    it 'adds child commands errors' do
      subject_instance.tap do |shell|
        shell.add(command = ElectricSheep::Metadata::Command.new(config,
                                                                 agent: 'cmd'))
        command.expects(:validate).returns(false)
        expects_validation_error(shell, :base, /Invalid command "cmd"/)
      end
    end
  end
end
