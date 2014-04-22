module ElectricSheep
  module Resources
    class FileSystem < Resource

      option :path, required: true
      option :remote
     
      def remote?
        remote == true
      end

      def basename
        ::File.basename(path)
      end

    end
  end
end
