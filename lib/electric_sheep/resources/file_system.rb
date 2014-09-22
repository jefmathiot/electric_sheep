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
        return option(:path) if option(:path).first == '/'
        return option(:host).working_directory+'/'+option(:path) if option(:host).working_directory
        raise "path for file #{option(:path)} is invalid please provide a working directory or provide relative path"
      end
    end
  end
end
