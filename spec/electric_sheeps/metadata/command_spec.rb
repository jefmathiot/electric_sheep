require 'spec_helper'

describe ElectricSheeps::Metadata::Command do

    before do
        @command = subject.new(id: 'command_id', agent: Object)
    end

    it 'should be bound to an agent class' do
        @command.agent.must_equal Object
    end

    it 'should have an id' do
        @command.id.must_equal 'command_id'
    end

end
