module ElectricSheep
  module Resources
    class S3Object < Resource
      include Extended

      option :directory
      option :bucket, required: true

      def initialize(opts)
        if path=opts.delete(:path)
          opts.merge!(normalize_path(path))
        end
        super
      end

    end
  end
end

