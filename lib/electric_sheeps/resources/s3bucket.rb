module ElectricSheeps
  module Resources
    class S3Bucket
      include Resource

      attr_accessor :url, :access_key, :secret_key
    end
  end
end
