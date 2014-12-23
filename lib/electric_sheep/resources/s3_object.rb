module ElectricSheep
  module Resources
    class S3Object < Resource
      include Extended

      option :directory
      option :bucket, required: true
      option :region

      def initialize(opts={})
        if path=opts.delete(:path)
          opts.merge!(normalize_path(path))
        end
        super
      end

      def local?
        false
      end

      def to_location
        Metadata::Pipe::Location.new(
          [bucket, directory].compact.join('/'), region, :bucket
        )
      end

    end
  end
end
