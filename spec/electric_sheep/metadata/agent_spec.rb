require 'spec_helper'

describe ElectricSheep::Metadata::Agent do
  include Support::Options

  it do
    defines_options :agent
    requires :agent
  end

  class AgentKlazz < ElectricSheep::Metadata::Agent
    option :secret, secret: true
    option :public
    option :default
  end

  describe AgentKlazz do
    let(:agent) { subject.new(secret: 'value', public: 'value') }

    it 'provides the public option as is' do
      agent.safe_option(:public).must_equal 'value'
    end

    it 'hides the value of the secret option' do
      agent.safe_option(:secret).must_equal '****'
    end

    it 'takes its type from class' do
      agent.type.must_equal 'agent_klazz'
    end

    it 'fetches default values for options' do
      ElectricSheep::Agents::Register.expects(:defaults_for)
        .with('agent_klazz', 'id').returns(default: 'value')
      subject.new(agent: 'id').option(:default).must_equal 'value'
    end

    it do
      ElectricSheep::Agents::Register.stubs(:agent_klazz).with('foo')
        .returns(nil)
      expects_validation_error(subject.new(agent: 'foo'), :agent_klazz,
                               'Unknown agent_klazz "foo"')
    end

    it 'resolves the agent class' do
      ElectricSheep::Agents::Register.expects(:agent_klazz).with('foo')
        .returns(Object)
      subject.new(agent: 'foo').agent_klazz.must_equal Object
    end
  end

  it 'merges its options with those of the agent class' do
    ElectricSheep::Agents::Register.stubs(:agent).with('foo')
      .returns(mock(options: { another_option: {} }))
    subject.new(agent: 'foo').options
      .must_equal(agent: { required: true }, another_option: {})
  end
end
