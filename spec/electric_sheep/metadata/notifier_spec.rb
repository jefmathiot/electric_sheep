require 'spec_helper'

describe ElectricSheep::Metadata::Notifier do
  include Support::Options

  it{
    defines_options :notifier
    requires :notifier
  }

  it{
    expects_validation_error(subject.new(notifier: 'foo'), :notifier,
      "Unknown notifier foo")
  }

  it 'resolves the agent class' do
    ElectricSheep::Agents::Register.expects(:notifier).with('foo').returns(Object)
    subject.new(notifier: 'foo').agent.must_equal Object
  end

end
