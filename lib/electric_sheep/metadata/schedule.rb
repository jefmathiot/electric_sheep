module ElectricSheep
  module Metadata
    module Schedule

      class Base < Metadata::Base
        attr_reader :scheduled_at

        def expired?
          Time.now >= scheduled_at
        end
      end

      class Hourly < Base
        option :past

        def next!
          @scheduled_at=Time.now.at_beginning_of_hour.in(1.hour)
          if option(:past)
            @scheduled_at=@scheduled_at.in(option(:past).to_i.minutes)
          end
        end

      end

      class Timed < Base
        option :at

        protected
        def at_time(time)
          at=(option(:at)||'').split(':')
          time.change(
            hour: at[0].to_i, min: at[1].to_i, sec: 0
          )
        end
      end

      class Daily < Timed
        def next!
          @scheduled_at=at_time(Time.now)
          @scheduled_at=@scheduled_at.in(1.day) if @scheduled_at < Time.now
        end
      end

      class Weekly < Timed
        option :on, required: true

        DAYS=%w(sunday monday tuesday wednesday thursday friday saturday).
          freeze

        def next!
          @scheduled_at=at_time(Time.now.at_beginning_of_week(:sunday)).
            in(DAYS.find_index(option(:on)).days)
          @scheduled_at=@scheduled_at.in(1.week) if @scheduled_at < Time.now
        end

      end

      class Monthly < Timed
        option :every

        def days_in_month(time)
          Time.days_in_month(time.month, time.year)
        end

        def next!
          day=option(:every) || 1
          basetime=at_time(Time.now)
          @scheduled_at=adjust(basetime, day)
          if @scheduled_at < Time.now
            @scheduled_at=adjust(basetime.in(1.month), day)
          end
        end

        protected
        def adjust(time, day)
          time.change(day: [day.to_i, days_in_month(time)].min)
        end
      end

    end
  end
end