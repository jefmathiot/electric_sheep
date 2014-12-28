require 'spec_helper'

describe ElectricSheep::Metadata::Transport do
  include Support::Hosts
  include Support::Options

  it{
    defines_options :action, :agent, :to
    requires :action, :agent, :to
  }

  it 'describes a copy' do
    subject.new(action: :copy).tap do |subject|
      subject.copy?.must_equal true
      subject.move?.must_equal false
    end
  end

  it 'describes a move' do
    subject.new(action: :move).tap do |subject|
      subject.move?.must_equal true
      subject.copy?.must_equal false
    end
  end

  it{
    expects_validation_error( subject.new(agent: 'foo'), :transport,
      'Unknown transport "foo"')
  }

  it 'resolves the agent class' do
    ElectricSheep::Agents::Register.expects(:transport).with('foo').returns(Object)
    subject.new(agent: 'foo').agent_klazz.must_equal Object
  end

end
