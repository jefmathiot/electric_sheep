require 'spec_helper'

describe ElectricSheeps::Metadata::Command do

  before do
    @command = subject.new(id: 'command_id', type: 'foo')
  end

  it 'resolves the agent class' do
    ElectricSheeps::Agents::Register.expects(:command).with('foo').returns(Object)
    @command.agent.must_equal Object
  end

  it 'adds a resource' do
    @command.add_resource :my_resource, 'some-value'
    @command.my_resource.must_equal 'some-value'
  end

  it 'raises an error if a resource is missing' do
    ->{ @command.my_resource }.must_raise NoMethodError
  end

  it 'is bound to an agent type' do
    @command.type.must_equal 'foo'
  end

  it 'should have an id' do
    @command.id.must_equal 'command_id'
  end

end
