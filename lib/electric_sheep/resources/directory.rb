module ElectricSheep
  module Resources
    class Directory
      include FileSystem
      
      def file?
        false
      end

      def directory?
        true
      end

    end
  end
end
