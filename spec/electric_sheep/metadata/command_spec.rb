require 'spec_helper'

describe ElectricSheep::Metadata::Command do
  include Support::Options

  it{
    defines_options :id, :type
    requires :id, :type
  }

  it{
    expects_validation_error(subject.new(type: 'foo'), :type, "Unknown command type foo")
  }

  it 'resolves the agent class' do
    ElectricSheep::Agents::Register.expects(:command).with('foo').returns(Object)
    subject.new(type: 'foo').agent.must_equal Object
  end

end
