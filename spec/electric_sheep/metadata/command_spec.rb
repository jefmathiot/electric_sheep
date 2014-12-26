require 'spec_helper'

describe ElectricSheep::Metadata::Command do
  include Support::Options

  it{
    defines_options :action
    requires :action
  }

  it{
    expects_validation_error(subject.new(action: 'foo'), :action,
      "Unknown command foo")
  }

  it 'resolves the agent class' do
    ElectricSheep::Agents::Register.expects(:command).with('foo').returns(Object)
    subject.new(action: 'foo').agent.must_equal Object
  end

end
