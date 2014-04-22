module ElectricSheep
  module Resources
    class S3Object < Resource

      option :key, required: true
      option :bucket, required: true
      option :access_key, required: true
      option :secret_key, required: true

    end
  end
end

