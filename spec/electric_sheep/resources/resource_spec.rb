require 'spec_helper'

describe ElectricSheep::Resources::Resource do
  include Support::Options

  it {
    defines_options :host
    requires :host
  }

  let(:origin){ mock }

  it 'uses original timestamp if any' do
    ts=Time.now.utc.strftime('%Y%m%d-%H%M%S')
    origin.expects(:timestamp?).returns(true)
    origin.expects(:timestamp).returns(ts)
    subject.new.tap do |resource|
      resource.timestamp!(origin)
      resource.timestamp.must_equal ts
    end
  end

  it 'creates a new timestamp' do
    Timecop.travel(Timecop.travel Time.utc(2014, 6, 5, 4, 3, 2)) do
      origin.expects(:timestamp?).returns(false)
      subject.new.tap do |resource|
        resource.timestamp!(origin)
        resource.timestamp.must_equal '20140605-040302'
      end
    end
  end

  it 'creates an empty stat' do
    subject.new.stat.wont_be_nil
  end

  it 'creates a stat with the given size' do
    subject.new.tap do |resource|
      resource.stat!(1024).must_equal resource
      resource.stat.size.must_equal 1024
    end
  end

end
