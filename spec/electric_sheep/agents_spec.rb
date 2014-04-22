require 'spec_helper'

describe ElectricSheep::Agents::Register do

  it 'should allow command registration' do
    class FakeCommand ; end
    subject.register command: FakeCommand, as: :fake
    subject.command("fake").must_equal FakeCommand
  end

  it 'should allow transport registration' do
    class FakeTransport ; end
    subject.register transport: FakeTransport, as: :fake
    subject.transport("fake").must_equal FakeTransport
  end
end
