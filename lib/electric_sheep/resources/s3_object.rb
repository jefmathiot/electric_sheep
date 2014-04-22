module ElectricSheep
  module Resources
    class S3Object < Resource

      property :key, required: true
      property :bucket, required: true
      property :access_key, required: true
      property :secret_key, required: true

    end
  end
end

