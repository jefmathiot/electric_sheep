module ElectricSheep
  module Resources
    class S3Object < Resource

      option :key, required: true
      option :bucket, required: true

    end
  end
end

