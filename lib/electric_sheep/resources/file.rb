module ElectricSheep
  module Resources
    class File < FileSystem

      def file?
        true
      end

      def directory?
        false
      end

    end
  end
end
