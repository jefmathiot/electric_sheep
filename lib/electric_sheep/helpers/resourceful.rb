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

      def s3_resource(key, bucket, options={})
        Resources::S3Object.new(options.merge(key: key, bucket: bucket))
      end
    end
  end
end
