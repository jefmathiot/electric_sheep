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
        return option(:path) if Pathname.new(option(:path)).absolute?
        ::File.join(option(:host).working_directory, option(:path))
      end
    end
  end
end
