require 'spec_helper'

describe ElectricSheeps::Agents::Register do

    it 'should allow command registration' do
        class FakeAgent ; end
        subject.register FakeAgent, as: "fake", of_type: :command
        subject.command("fake").must_equal FakeAgent
        FakeAgent.ancestors.select{|ancestor| ancestor == ElectricSheeps::Agents::Command}.size.must_equal 1, 'FakeAgent should include ElectricSheeps::Agents::Command'
    end

end
