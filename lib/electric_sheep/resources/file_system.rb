module ElectricSheep
  module Resources
    class FileSystem < Resource

      property :path, required: true
      property :remote
     
      def remote?
        remote == true
      end

      def basename
        ::File.basename(path)
      end

    end
  end
end
