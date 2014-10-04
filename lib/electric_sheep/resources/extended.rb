module ElectricSheep
  module Resources
    module Extended
      extend ActiveSupport::Concern
      include Named

      included do
        option :extension
      end

      protected
      def name_items
        (super << extension)
      end

    end
  end
end