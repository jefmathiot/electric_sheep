module ElectricSheep
  module Commands
    module S3
      class S3cmd
        include ElectricSheep::Commands::Command
        include ElectricSheep::Helpers::ShellSafe

        register as: 's3cmd'

        prerequisite :check_s3cmd

        option :access_key, required: true
        option :secret_key, required: true

        def perform
          logger.info %{Uploading file "#{resource.basename}" to S3 bucket "#{option(:bucket)}"}
          shell.exec %{s3cmd put "#{resource.path}" "s3://#{shell_safe(option(:bucket))}" } << 
            %{--access_key="#{shell_safe(option(:access_key))}" } <<
            %{--secret_key="#{shell_safe(option(:secret_key))}"}
            done! Resources::S3Object.new( bucket: option(:bucket),
              access_key: option(:access_key),
              secret_key: option(:secret_key),
              key: resource.basename )
        end

        def check_s3cmd
          # TODO Check s3cmd minimal version
        end

      end
    end
  end
end
