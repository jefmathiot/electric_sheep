module ElectricSheep
  module Metadata
    class Job < Configured
      include Pipe
      include Monitor

      option :id, required: true
      option :description
      option :private_key

      attr_reader :starts_with

      def start_with!(resource)
        @starts_with = resource
      end

      def notifier(metadata)
        notifiers << metadata
      end

      def validate
        queue.each do |step|
          unless step.validate
            errors.add(:base, "Invalid step #{step}", step.errors)
          end
        end
        super
      end

      def schedule!(schedule)
        schedules << schedule
      end

      def schedules
        @schedules ||= []
      end

      def on_schedule(&_)
        return unless schedules.reduce(false) do |expired, schedule|
          expired || schedule.expired?
        end
        schedules.map(&:update!)
        yield self
      end

      def name
        description.nil? ? "#{id}" : "#{description} (#{id})"
      end

      def notifiers
        @notifiers ||= []
      end
    end
  end
end
