module ElectricSheeps
  module Resources
    class S3Bucket
      include Resource

      options :url, :access_key, :secret_key
    end
  end
end
