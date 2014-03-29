require 'spec_helper'

describe ElectricSheeps::Commands::Register do

  it 'should allow command registration' do
    class FakeAgent ; end
    subject.register FakeAgent, as: "fake", of_type: :command
    subject.command("fake").must_equal FakeAgent
    FakeAgent.ancestors.select{|ancestor| ancestor == ElectricSheeps::Commands::Command}.size.must_equal 1, 'FakeAgent should include ElectricSheeps::Commands::Command'
  end

end
