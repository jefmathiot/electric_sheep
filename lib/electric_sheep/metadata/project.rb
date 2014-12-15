module ElectricSheep
  module Metadata
    class Project < Base
      include Queue
      include Monitor

      option :id, required: true
      option :description

      attr_accessor :products
      attr_reader :schedule

      def initialize(options={})
        super
        reset!
        @products = []
      end

      def start_with!(resource)
        @initial_resource = resource
      end

      def use_private_key!(key)
        @private_key=key
      end

      def store_product!(resource)
        @products << resource
      end

      def last_product
        @products.last || @initial_resource
      end

      def private_key
        @private_key || File.expand_path('~/.ssh/id_rsa')
      end

      def validate(config)
        all.each do |step|
          unless step.validate(config)
            errors.add(:base, "Invalid step #{step.to_s}", step.errors)
          end
        end
        super
      end

      def schedule!(schedule)
        @schedule = schedule
      end

      def on_schedule(&block)
        if @schedule && @schedule.expired?
          @schedule.update!
          yield self
        end
      end

      def name
        description.nil? ? "\"#{id}\"" : "\"#{description}\" (#{id})"
      end

      def successful?
        @status==:success
      end

      def mark!(status)
        @status=status
      end

    end
  end
end
