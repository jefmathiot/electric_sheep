require 'spec_helper'

describe ElectricSheep::Metadata::Command do
  include Support::Options

  it{
    defines_options :id, :type
    requires :id, :type
  }

  before do
    @command = subject.new(type: 'foo')
  end

  it{
    expects_validation_error(@command, :type, "Unknown command type foo")
  }

  it 'resolves the runner class' do
    ElectricSheep::Agents::Register.expects(:command).with('foo').returns(Object)
    @command.agent.must_equal Object
  end

end
