require 'date'

class DateTime

  def next_week
    self + (7 - self.wday)
  end

  def next_wday(n)
    n > self.wday ? self + (n - self.wday) : self.next_week.next_day(n)
  end

  def next_month
    d = Date.new(self.year, self.month, self.day)
    d >>= 1
    DateTime.new(d.year, d.month, [d.day,d.end_of_month.day].min, self.hour, self.min, self.sec, self.usec)
  end

  def reset_time(time='00:00:00')
    DateTime.parse self.strftime("%F ") + time
  end

end

module ElectricSheep
  module Metadata
    class Schedule < Base

      WEEKDAY_NAMES = %w<sunday monday tuesday wednesday thursday friday saturday>

      option :rate # daily, hourly, weekly, monthly
      option :on
      option :at
      option :every

      def initialize(options={})
        super
        @options[:on] ||= "00:00" #TODO add an option to Option :)
        @options[:at] ||= "00:00" #TODO add an option to Option :)
      end

      def launchable?(previous, current)
        next_launch = send("next_#{rate}_launch_time",previous)
        in_range?(previous, current, next_launch)
      end

      def next_daily_launch_time(date_time)
        next_time = date_time.reset_time option(:on)
        next_time < date_time ? next_time + 1.day : next_time
      end

      def next_hourly_launch_time(date_time)
        next_time = date_time.change({ hour: date_time.hour, min: 0, sec: 0 })
        next_time < date_time ? next_time += 1.hour : next_time
      end

      def next_weekly_launch_time(date_time)
        wday = WEEKDAY_NAMES.index(option(:on).downcase) || 0
        next_time = date_time
        next_time = date_time.next_wday( wday ) if date_time.wday != wday
        next_time = next_time.reset_time option(:at)
        date_time.reset_time option(:at)
        next_time < date_time ? next_time + 7.day : next_time
      end

      def next_monthly_launch_time(date_time)
        day =  [option(:every).to_i || 1, date_time.end_of_month.day].min
        next_time = date_time + (day - date_time.day)
        next_time = next_time.reset_time option(:at)
        next_time < date_time ? next_time.next_month : next_time
      end

      protected

      def in_range?(previous, current, launch_datetime)
        previous < launch_datetime && launch_datetime <= current
      end

    end
  end
end
