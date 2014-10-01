require 'fog'

module ElectricSheep
  module Transports
    class S3
      include Transport
      include Helpers::Resourceful

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
          operation.create(resource, bucket, key)
          operation.destroy(resource) if delete_source
          exec_done(bucket, key, delete_source)
        end
      end

      def operation
        if option(:to) == 'localhost'
          DownloadOperation.new(connection)
        else
          UploadOperation.new(connection)
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
        # TODO Move somewhere else ?
        if ENV['ELECTRIC_SHEEP_ENV']=='test'
          {
            provider: 'local',
            local_root: './tmp/s3',
            endpoint: 'http://s3.amazonaws.com'
          }
        else
          {
            provider: 'AWS',
            aws_access_key_id: option(:access_key_id),
            aws_secret_access_key: option(:secret_key)
          }
        end
      end

      def exec_done(bucket, key, delete_source=nil)
        if delete_source
          if option(:to) == 'localhost'
            # TODO
          else
            done! s3_resource(bucket, key)
          end
        else
          done! resource
        end
      end

      class Operation
        def initialize(connection)
          @connection = connection
        end

        def remote_directory(bucket)
          @connection.directories.get(bucket)
        end

      end

      class UploadOperation < Operation

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

      class DownloadOperation < Operation

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
