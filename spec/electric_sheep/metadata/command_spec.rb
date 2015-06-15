require 'spec_helper'

describe ElectricSheep::Metadata::Command do
  include Support::Options

  it do
    defines_options :agent
    requires :agent
  end

  it do
    expects_validation_error(subject.new(agent: 'foo'), :command,
                             'Unknown command "foo"')
  end

  it 'resolves the agent class' do
    ElectricSheep::Agents::Register.expects(:command).with('foo')
      .returns(Object)
    subject.new(agent: 'foo').agent_klazz.must_equal Object
  end
end
