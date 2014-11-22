require 'spec_helper'

describe ElectricSheep::Agents::Register do

  it 'register commands' do
    class FakeCommand ; end
    subject.register command: FakeCommand, as: :fake
    subject.command("fake").must_equal FakeCommand
  end

  it 'registers transports' do
    class FakeTransport ; end
    subject.register transport: FakeTransport, as: :fake
    subject.transport("fake").must_equal FakeTransport
  end

  it 'registers notifiers' do
    class FakeNotifier ; end
    subject.register notifier: FakeNotifier, as: :fake
    subject.notifier("fake").must_equal FakeNotifier
  end
end
