module ElectricSheep
  module Resources
    class S3Object < Metadata::Base

      option :key, required: true
      option :bucket, required: true

    end
  end
end

