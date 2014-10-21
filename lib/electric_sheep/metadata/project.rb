module ElectricSheep
  module Metadata
    class Project < Base
      include Queue
      include Metered

      option :id, required: true
      option :description

      attr_accessor :products

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
        each_item do |step|
          unless step.validate(config)
            errors.add(:base, "Invalid step #{step.to_s}", step.errors)
          end
        end
        reset!
        super
      end

      def add_schedule(schedule)
        @schedules ||= []
        @schedules.push schedule
      end

    end
  end
end
