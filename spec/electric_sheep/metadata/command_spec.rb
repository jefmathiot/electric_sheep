require 'spec_helper'

describe ElectricSheeps::Metadata::Command do

  before do
    @command = subject.new(type: 'foo')
  end

  it 'resolves the runner class' do
    ElectricSheeps::Commands::Register.expects(:command).with('foo').returns(Object)
    @command.command_runner.must_equal Object
  end

  it 'is bound to an agent type' do
    @command.type.must_equal 'foo'
  end

end
