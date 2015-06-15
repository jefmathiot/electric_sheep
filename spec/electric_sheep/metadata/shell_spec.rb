require 'spec_helper'

describe ElectricSheep::Metadata::Shell do
  include Support::ShellMetadata
  include Support::Options
  include Support::Queue

  def queue_items
    ([0] * 2).map do
      ElectricSheep::Metadata::Command.new
    end
  end

  describe 'validating' do
    it 'adds child commands errors' do
      subject.new.tap do |shell|
        shell.add(command = ElectricSheep::Metadata::Command.new(agent: 'cmd'))
        command.expects(:validate).with(instance_of(ElectricSheep::Config))
          .returns(false)
        expects_validation_error(shell, :base, /Invalid command "cmd"/)
      end
    end
  end
end
