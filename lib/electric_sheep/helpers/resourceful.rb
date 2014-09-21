module ElectricSheep
  module Helpers
    module Resourceful

      def directory_resource(host, path, options={})
        Resources::Directory.new(resource_options(host, path, options))
      end

      def file_resource(host, path, options={})
        Resources::File.new(resource_options(host, path, options))
      end

      def resource_options(host, path, options={})
        options.merge(host: host, path: path)
      end
    end
  end
end
