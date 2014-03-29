module ElectricSheeps
  module Commands
    module S3
      class S3cmd
        include ElectricSheeps::Commands::Command

        register as: 's3cmd', of_type: :command

        resource :file, kind_of: Resources::File
        resource :s3_bucket, kind_of: Resources::S3Bucket

        def perform
          logger.info 'Uploading to S3 bucket'
          puts "s3cmd #{file.filename} #{s3_bucket.url} --access_key=#{s3_bucket.access_key} --access_key=#{s3_bucket.secret_key}"
          shell.exec "s3cmd #{file.filename} #{s3_bucket.url} --access_key=#{s3_bucket.access_key} --access_key=#{s3_bucket.secret_key}"
        end
      end
    end
  end
end
