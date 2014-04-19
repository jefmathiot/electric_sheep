module ElectricSheep
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

      include Options
      options :id, :description

    end
  end
end
