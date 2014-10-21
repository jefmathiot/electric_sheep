require 'spec_helper'

describe ElectricSheep::Metadata::Schedule do

  describe "define default values" do

    before do
      @schedule = subject.new(rate: 'daily')
    end

    it "set :at option" do
      @schedule.send("option",:at).must_equal "00:00"
    end

    it "set :on option" do
      @schedule.send("option",:on).must_equal "00:00"
    end

  end

  describe "in_range?" do

    before do
      @schedule = subject.new()
    end

    it "confirm datetime when in range" do
      first    = DateTime.parse('2010-01-10 13:00:00')
      last     = DateTime.parse('2010-01-10 15:00:00')
      check    = DateTime.parse('2010-01-10 14:00:00')
      @schedule.send("in_range?",first, last, check).must_equal true
    end

    it "refute datetime when out of range" do
      first    = DateTime.parse('2010-01-10 13:00:00')
      last     = DateTime.parse('2010-01-10 15:00:00')
      check    = DateTime.parse('2010-01-10 16:00:00')
      @schedule.send("in_range?",first, last, check).must_equal false
    end

    it "refute datetime when on left threshold range" do
      first    = DateTime.parse('2010-01-10 13:00:00')
      last     = DateTime.parse('2010-01-10 13:00:00')
      check    = DateTime.parse('2010-01-10 16:00:00')
      @schedule.send("in_range?",first, last, check).must_equal false
    end

    it "refute datetime when on right threshold range" do
      first    = DateTime.parse('2010-01-10 13:00:00')
      last     = DateTime.parse('2010-01-10 16:00:00')
      check    = DateTime.parse('2010-01-10 16:00:00')
      @schedule.send("in_range?",first, last, check).must_equal true
    end

  end

  describe "launchable?" do
    [:hourly,:daily,:weekly,:monthly].each do |rate|
      it "handle #{rate} " do
        @schedule = subject.new(rate: rate.to_s)
        first = DateTime.parse('2010-01-10 12:00:05')
        last = DateTime.parse('2014-01-10 12:00:05')
        @schedule.expects("next_#{rate}_launch_time").with(first).returns(last = DateTime.parse('2012-01-10 12:00:05'))
        @schedule.launchable?(first, last).must_equal true
      end
    end
  end

  describe "next_hourly_launch_time" do

      before do
         @schedule = subject.new(rate: 'hourly')
      end

      it "return next launch time on same day" do
        time = DateTime.parse('2010-01-10 12:00:05')
        @schedule.next_hourly_launch_time(time).must_equal DateTime.parse('2010-01-10 13:00:00')
      end

      it "return next launch time on next day" do
        time = DateTime.parse('2010-12-31 23:10:10')
        @schedule.next_hourly_launch_time(time).must_equal DateTime.parse('2011-01-01 00:00:00')
      end

      it "return next launch time when on threshold" do
        time = DateTime.parse('2010-12-31 00:00:00')
        @schedule.next_hourly_launch_time(time).must_equal DateTime.parse('2010-12-31 00:00:00')
      end

  end

  describe "next_daily_launch_time" do

      before do
        @schedule = subject.new(rate: 'daily', on:'00:10:11')
      end

      it "return next launch time on same day" do
        time = DateTime.parse('2010-01-10 00:10:10')
        @schedule.next_daily_launch_time(time).must_equal DateTime.parse('2010-01-10 00:10:11')
      end

      it "return next launch time on next day" do
        time = DateTime.parse('2010-12-31 10:10:10')
        @schedule.next_daily_launch_time(time).must_equal DateTime.parse('2011-01-01 00:10:11')
      end

      it "return next launch time when on threshold" do
        time = DateTime.parse('2010-12-31 00:10:11')
        @schedule.next_daily_launch_time(time).must_equal DateTime.parse('2010-12-31 00:10:11')
      end

  end

  describe "next_weekly_launch_time" do

      before do
        @schedule = subject.new(rate: 'weekly', on: 'monday', at:'05:05:05')
      end

      it "return next launch time on same day" do
        time = DateTime.parse('2014-10-06 00:00:10')
        @schedule.next_weekly_launch_time(time).must_equal DateTime.parse('2014-10-06 05:05:05')
      end

      it "return next launch time on next week" do
        time = DateTime.parse('2014-12-31 10:10:10')
        @schedule.next_weekly_launch_time(time).must_equal DateTime.parse('2015-01-05 05:05:05')
      end

      it "return next launch time when on threshold" do
        time = DateTime.parse('2014-10-06 05:05:05')
        @schedule.next_weekly_launch_time(time).must_equal DateTime.parse('2014-10-06 05:05:05')
      end

  end

  describe "next_monthly_launch_time" do

      before do
        @schedule = subject.new(rate: 'monthly', every: '6', at:'05:05')
      end

      it "return next launch time on same day" do
        time = DateTime.parse('2014-01-06 00:00:10')
        @schedule.next_monthly_launch_time(time).must_equal DateTime.parse('2014-01-06 05:05:00')
      end

      it "return next launch time on next month" do
        time = DateTime.parse('2014-12-31 10:10:10')
        @schedule.next_monthly_launch_time(time).must_equal DateTime.parse('2015-01-06 05:05:00')
      end

      it "return next launch time when on threshold" do
        time = DateTime.parse('2015-01-06 05:05:00')
        @schedule.next_monthly_launch_time(time).must_equal DateTime.parse('2015-01-06 05:05:00')
      end

      it "return next launch time when on tiny month" do
        @schedule = subject.new(rate: 'monthly', every: '31', at:'05:05')
        time = DateTime.parse('2014-01-31 10:05:00')
        @schedule.next_monthly_launch_time(time).must_equal DateTime.parse('2014-02-28 05:05:00')
      end

  end

  describe "DateTime" do

    it "return next start week day" do
      @subject = DateTime.parse('2014-12-31 05:05:00')
      @subject.wday.must_equal 3
      @subject.next_week.must_equal DateTime.parse('2015-01-04 05:05:00')
      @subject.next_week.wday.must_equal 0
    end

    it "return next start week day on sunday" do
      @subject = DateTime.parse('2015-01-04 05:05:00')
      @subject.next_week.must_equal DateTime.parse('2015-01-11 05:05:00')
      @subject.next_week.wday.must_equal 0
    end

    it "return next month" do
      @subject = DateTime.parse('2014-01-31 05:05:00')
      @subject.next_month.must_equal DateTime.parse('2014-02-28 05:05:00')
    end

    it "reset time" do
      @subject = DateTime.parse('2014-01-31 08:43:43')
      @subject.reset_time("12:34:56").must_equal DateTime.parse('2014-01-31 12:34:56')
    end
  end

end
