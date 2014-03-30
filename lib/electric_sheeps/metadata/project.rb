module ElectricSheeps
  module Metadata
    class Project
      include Queue
      include Metered

      attr_accessor :description, :products

      def initialize
        reset!
        @products = {}.with_indifferent_access
      end

      def store_product(step_id, resource)
        @products[step_id] = resource
      end

      def product_of(step_id)
        @products[step_id]
      end

      include Options
      options :id

    end
  end
end
