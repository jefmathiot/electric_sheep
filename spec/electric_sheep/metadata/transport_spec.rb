require 'spec_helper'

describe ElectricSheep::Metadata::Transport do
  include Support::Hosts
  include Support::Options

  let(:config) do
    ElectricSheep::Config.new
  end

  it do
    defines_options :action, :agent, :to
    requires :action, :agent, :to
  end

  it 'describes a copy' do
    subject.new(config, action: :copy).tap do |subject|
      subject.copy?.must_equal true
      subject.move?.must_equal false
    end
  end

  it 'describes a move' do
    subject.new(config, action: :move).tap do |subject|
      subject.move?.must_equal true
      subject.copy?.must_equal false
    end
  end

  it do
    expects_validation_error(subject.new(config, agent: 'foo'), :transport,
                             'Unknown transport "foo"')
  end

  it 'resolves the agent class' do
    ElectricSheep::Agents::Register
      .expects(:transport).with('foo')
      .returns(Object)
    subject.new(config, agent: 'foo').agent_klazz.must_equal Object
  end
end
