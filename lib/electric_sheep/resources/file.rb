module ElectricSheep
  module Resources
    class File < FileSystem

      option :extension

      def file?
        true
      end

      def directory?
        false
      end

      protected
      def name_items
        (super << extension)
      end

    end
  end
end
