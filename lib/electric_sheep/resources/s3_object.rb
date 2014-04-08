module ElectricSheep
  module Resources
    class S3Object
      include Resource

      options :key, :bucket, :access_key, :secret_key

    end
  end
end

