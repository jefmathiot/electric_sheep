require 'spec_helper'

describe ElectricSheep::Metadata::Agent do
  include Support::Options

  it do
    defines_options :agent
    requires :agent
  end

  let(:config) do
    ElectricSheep::Config.new
  end

  class AgentKlazz < ElectricSheep::Metadata::Agent
    option :secret, secret: true
    option :public
    option :foobar, default: 'local'
  end

  describe AgentKlazz do
    let(:agent) { subject.new(config, secret: 'value', public: 'value') }

    it 'provides the public option as is' do
      agent.safe_option(:public).must_equal 'value'
    end

    it 'hides the value of the secret option' do
      agent.safe_option(:secret).must_equal '****'
    end

    it 'takes its type from class' do
      agent.type.must_equal 'agent_klazz'
    end

    describe 'fetching default values' do
      before do
        ElectricSheep::Agents::Register.stubs(:agent_klazz).with('id')
          .returns(nil)
      end

      it 'fetches a globally defined default value for option' do
        ElectricSheep::Agents::Register.expects(:defaults_for)
          .with('agent_klazz', 'id').returns(foobar: 'value')
        subject.new(config, agent: 'id').option(:foobar).must_equal 'value'
      end

      it 'prefers a default a locally defined default value for option' do
        ElectricSheep::Agents::Register.expects(:defaults_for)
          .returns({})
        subject.new(config, agent: 'id').option(:foobar).must_equal 'local'
      end
    end

    it 'does not validate unless the agent is known' do
      ElectricSheep::Agents::Register.stubs(:agent_klazz).with('foo')
        .returns(nil)
      expects_validation_error(subject.new(config, agent: 'foo'), :agent_klazz,
                               'Unknown agent_klazz "foo"')
    end

    it 'resolves the agent class' do
      ElectricSheep::Agents::Register.expects(:agent_klazz).with('foo')
        .returns(Object)
      subject.new(config, agent: 'foo').agent_klazz.must_equal Object
    end
  end

  it 'merges its options with those of the agent class' do
    ElectricSheep::Agents::Register.stubs(:agent).with('foo')
      .returns(mock(options: { another_option: {} }))
    subject.new(config, agent: 'foo').options
      .must_equal(agent: { required: true }, another_option: {})
  end
end
