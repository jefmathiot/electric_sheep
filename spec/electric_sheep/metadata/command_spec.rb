require 'spec_helper'

describe ElectricSheep::Metadata::Command do
  include Support::Options

  it{
    defines_options :agent
    requires :agent
  }

  it{
    expects_validation_error(subject.new(agent: 'foo'), :command,
      'Unknown command "foo"')
  }

  it 'resolves the agent class' do
    ElectricSheep::Agents::Register.expects(:command).with('foo').returns(Object)
    subject.new(agent: 'foo').agent_klazz.must_equal Object
  end

end
