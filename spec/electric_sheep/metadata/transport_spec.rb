require 'spec_helper'

describe ElectricSheep::Metadata::Transport do
  include Support::Hosts
  include Support::Options

  it{
    defines_options :type, :transport, :to
    requires :type, :transport, :to
  }

  it 'describes a copy' do
    subject.new(type: :copy).tap do |subject|
      subject.copy?.must_equal true
      subject.move?.must_equal false
    end
  end

  it 'describes a move' do
    subject.new(type: :move).tap do |subject|
      subject.move?.must_equal true
      subject.copy?.must_equal false
    end
  end

  it{
    expects_validation_error(subject.new(type: 'foo'), :type, "Unknown agent type foo")
  }

  it 'resolves the agent class' do
    ElectricSheep::Agents::Register.expects(:transport).with('foo').returns(Object)
    subject.new(transport: 'foo').agent.must_equal Object
  end

end

