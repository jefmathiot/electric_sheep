require 'spec_helper'

describe ElectricSheeps::Commands::Register do

  it 'should allow command registration' do
    class FakeAgent ; end
    subject.register FakeAgent, as: "fake"
    subject.command("fake").must_equal FakeAgent
  end

end
