require 'spec_helper'

describe ElectricSheep::Agents::Register do

  class FakeCommand ; end
  class FakeTransport ; end
  class FakeNotifier ; end

  {command: FakeCommand, transport: FakeTransport, notifier: FakeNotifier}.
    each do |type, klazz|

    describe "with a #{type} registered" do

      before do
        subject.register type => klazz, as: :fake
      end

      it "resolves the class for #{type}" do
        subject.send(type, "fake").must_equal klazz
      end

      it "allows assignment of default options for #{type}" do
        subject.set_defaults_for(type => 'fake', an_option: 'value')
        subject.defaults_for(type, 'fake').must_equal({'an_option' => 'value'})
      end

    end

    it "raises when assigning defaults for an unknown #{type}" do
      options=
      ex = ->{ subject.set_defaults_for({type => 'xxxx'}) }.
        must_raise RuntimeError
      ex.message.must_equal "Can't assign default options for the unknown " +
        "#{type} xxxx"
    end

  end

end
