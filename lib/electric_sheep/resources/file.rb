module ElectricSheep
  module Resources
    class File < FileSystem
      include Extended

      def file?
        true
      end

      def directory?
        false
      end
    end
  end
end
