module ElectricSheep
  module Resources
    class FileSystem < Resource

      option :path, required: true

      def remote?
        !local?
      end

      def local?
        host.nil? || host.local?
      end

      def basename
        ::File.basename(path)
      end

      def path
        option(:path)
      end
    end
  end
end
