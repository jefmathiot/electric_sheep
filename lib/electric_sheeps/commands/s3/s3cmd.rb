module ElectricSheeps
  module Commands
    module S3
      class S3cmd
        include ElectricSheeps::Commands::Command

        register as: 's3cmd', of_type: :command

        resource :file, kind_of: Resources::File
        resource :s3_bucket, kind_of: Resources::S3Bucket
        prerequisite :check_s3cmd

        def perform
          logger.info 'Uploading to S3 bucket'
          shell.exec "s3cmd put #{file.filename} #{s3_bucket.url}/#{file.filename} --access_key=#{s3_bucket.access_key} --access_key=#{s3_bucket.secret_key}"
        end

        def check_s3cmd

        end
      end
    end
  end
end
