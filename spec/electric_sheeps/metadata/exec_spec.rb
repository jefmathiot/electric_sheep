require 'spec_helper'

describe ElectricSheeps::Metadata::Exec do

    before do
        @exec = subject.new(id: 'exec_id', agent: Object)
    end

    it 'should be bound to an agent class' do
        @exec.agent.must_equal Object
    end

    it 'should have an id' do
        @exec.id.must_equal 'exec_id'
    end

end
