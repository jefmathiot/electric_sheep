module ElectricSheeps
  module Metadata
    class Project
      include Queue
      include Metered

      attr_accessor :description, :products

      def initialize
        reset!
        @products = []
      end

      def start_with!(resource)
        @initial_resource = resource
      end

      def store_product!(resource)
        @products << resource
      end

      def last_product
        @products.last || @initial_resource
      end

      include Options
      options :id, :description

    end
  end
end
