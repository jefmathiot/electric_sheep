require 'spec_helper'

describe ElectricSheep::Metadata::Notifier do
  include Support::Options

  it{
    defines_options :agent
    requires :agent
  }

  it{
    expects_validation_error(subject.new(agent: 'foo'), :notifier,
      'Unknown notifier "foo"')
  }

  it 'resolves the agent class' do
    ElectricSheep::Agents::Register.expects(:notifier).with('foo').
      returns(Object)
    subject.new(agent: 'foo').agent_klazz.must_equal Object
  end

end
