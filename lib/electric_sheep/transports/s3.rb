require 'fog'

module ElectricSheep
  module Transport
    class S3
      include Transport

      register as: "s3"

      option :access_key_id, required: true
      option :secret_key, required: true

      def copy
        operate
      end

      def move
        operate true
      end

      protected
      def operate(delete_source=false)
        logger.info "#{delete_source ? 'Moving' : 'Copying'} " +
          "#{resource.basename} to #{option(:to)} using S3"
        with_object_key do |bucket, key|
          interactor.create(resource, bucket, key)
          interactor.destroy(resource, bucket, key) if delete_source
        end
      end

      def interactor
        if option(:to) == 'localhost'
          DownloadInteractor.new(connection)
        else
          UploadInteractor.new(connection)
        end
      end

      def with_object_key(&block)
        option(:to).split('/').tap do |paths|
          bucket = paths.shift
          paths << resource.basename
          yield bucket, paths.join('/')
        end
      end

      def connection
        Fog::Storage.new options
      end

      def options
        base_options.merge(
          aws_access_key_id: option(:access_key_id),
          aws_secret_access_key: option(:secret_key)
        )
      end

      def base_options
        if ENV['ELECTRIC_SHEEP_ENV']='test'
          {
            provider: 'local',
            local_root: './tmp/s3',
            endpoint: 'http://s3.amazonaws.com'
          }
        else
          {
            provider: 'AWS'
          }
        end
      end

      class Interactor
        def initialize(connection)
          @connection = connection
        end
      
        def remote_directory(bucket)
          @connection.directories.get(bucket)
        end

      end

      class UploadInteractor < Interactor

        def create(resource, bucket, key)
          remote_directory(bucket).files.create(
            key: key,
            body: File.open( resource.path ),
            multipart_chunk_size: 100.megabytes
          )
        end

        def destroy(resource, bucket, key)
          FileUtils.rm_f resource.path
        end

      end

      class DownloadInteractor < Interactor

        def create(resource, bucket, key)
          raise "Not implemented"
        end

        def destroy(resource, bucket, key)
          raise "Not implemented"
        end

      end

    end
  end
end
