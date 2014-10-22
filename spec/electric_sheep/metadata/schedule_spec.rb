require 'spec_helper'


describe ElectricSheep::Metadata::Schedule do

  before {  Timecop.travel(Time.local(2014, 1, 1, 1, 0, 0)) }
  after { Timecop.return }

  def expects_scheduled_at(options, expected)
    subject.new(options).tap do |subject|
      subject.next!
      assert_equal expected, subject.scheduled_at
    end
  end

  describe ElectricSheep::Metadata::Schedule::Base do
    it 'expires' do
      subject.new.tap do |schedule|
        schedule.instance_variable_set(:@scheduled_at, Time.now - 1.second)
        assert_equal true, schedule.expired?
      end
    end
  end

  describe ElectricSheep::Metadata::Schedule::Hourly do
    include Support::Options

    it{ defines_options :past }

    it 'schedules at the beginning of the next hour' do
        expects_scheduled_at({}, Time.local(2014, 1, 1, 2, 0, 0))
      end

    it 'schedules at the middle of the next hour' do
      expects_scheduled_at({past: '30'}, Time.local(2014, 1, 1, 2, 30, 0))
    end

  end

  describe ElectricSheep::Metadata::Schedule::Daily do
    include Support::Options

    it{ defines_options :at }

    it 'schedules at the given hour the same day' do
      expects_scheduled_at({at: "02:30"}, Time.local(2014, 1, 1, 2, 30, 0))
    end

    it 'schedules at the given hour the next day' do
      expects_scheduled_at({at: '00:30'}, Time.local(2014, 1, 2, 0, 30, 0))
    end

    it 'defaults to midnight' do
      expects_scheduled_at({}, Time.local(2014, 1, 2, 0, 0, 0))
    end

  end

  describe ElectricSheep::Metadata::Schedule::Weekly do
    include Support::Options

    it{ defines_options :at, :on }

    it 'schedules at the given hour and day the same week' do
      expects_scheduled_at({on: "wednesday", at: "02:30"},
        Time.local(2014, 1, 1, 2, 30, 0))
    end

    it 'schedules at the given hour and day the next week' do
      expects_scheduled_at({on: "wednesday", at: '00:30'},
        Time.local(2014, 1, 8, 0, 30, 0))
    end

    it 'defaults to midnight' do
      expects_scheduled_at({on: "thursday"}, Time.local(2014, 1, 2, 0, 0, 0))
    end

  end

  describe ElectricSheep::Metadata::Schedule::Monthly do
    include Support::Options

    it{ defines_options :at, :every }

    describe 'with enough days in month' do
      it 'schedules at the given hour and day in the same month' do
        expects_scheduled_at({every: "1", at: "02:30"},
          Time.local(2014, 1, 1, 2, 30, 0))
      end

      it 'schedules at the given hour and day in the next month' do
        expects_scheduled_at({every: "1", at: '00:30'},
          Time.local(2014, 2, 1, 0, 30, 0))
      end
    end

    describe 'with a day out of range' do
      it 'schedules at the given hour and day in the same month' do
        expects_scheduled_at({every: "32", at: "02:30"},
          Time.local(2014, 1, 31, 2, 30, 0))
      end

      it 'schedules at the given hour and day in the next month' do
        Timecop.travel(Time.local(2014, 1, 31, 1, 0, 0)) do
          expects_scheduled_at({every: "32", at: '00:30'},
            Time.local(2014, 2, 28, 0, 30, 0))
        end
      end
    end

    it 'defaults to midnight' do
      expects_scheduled_at({every: "1"}, Time.local(2014, 2, 1, 0, 0, 0))
    end

    it 'defaults to first day in month' do
      expects_scheduled_at({}, Time.local(2014, 2, 1, 0, 0, 0))
    end

  end

end