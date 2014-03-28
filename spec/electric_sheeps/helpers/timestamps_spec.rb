require 'spec_helper'
require 'timecop'

describe ElectricSheeps::Helpers::Timestamps do
  TimestampsKlazz = Class.new do
    include ElectricSheeps::Helpers::Timestamps
  end

  describe TimestampsKlazz do
    it 'generates a timestamp' do
      Timecop.travel(Time.utc(1879, 3, 14, 11, 30, 0))
      subject.new.timestamp.must_equal '18790314-113000'
      Timecop.return
    end
  end

end
