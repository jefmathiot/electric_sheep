module ElectricSheep
  module Resources
    class S3Object < Metadata::Base

      option :key, required: true
      option :bucket, required: true

      def basename
        Pathname.new(key).basename.to_s
      end

    end
  end
end

