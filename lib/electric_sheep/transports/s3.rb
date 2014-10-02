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
        operation(delete_source).perform! do |options|
          exec_done(options)
        end
      end

      def operation(delete_source)
        with_object_key do |bucket, key|
          operation_options = {
            connection: connection,
            bucket: bucket,
            key: key,
            resource: resource,
            delete_source: delete_source,
            to: option(:to),
            host: host(option(:to)),
            local_interactor: local_interactor
          }
          if option(:to) == 'localhost'
            return DownloadOperation.new(operation_options)
          else
            return UploadOperation.new(operation_options)
          end
        end
      end

      def with_object_key(&block)
        if option(:to) == 'localhost'
          yield resource.bucket, resource.key
        else
          option(:to).split('/').tap do |paths|
            bucket = paths.shift
            paths << resource.basename
            yield bucket, paths.join('/')
          end
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
            local_root: File.basename(Dir.pwd) == 'tmp' ? './s3' : './tmp/s3',
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

      def exec_done(args={})
        if args[:delete_source]
          if option(:to) == 'localhost'
            new_resource = file_resource(args[:host], args[:path])
          else
            new_resource = s3_resource(args[:bucket], args[:key])
          end
        else
          new_resource = resource
        end
        done! new_resource
      end

      class Operation
        def initialize(options)
          @options = options
        end

        [:connection, :bucket, :key, :resource, :delete_source, :to, :host, :local_interactor].each do |method|
          define_method method do
            @options[method]
          end
        end

        def remote_directory
          connection.directories.get(bucket)
        end
      end

      class UploadOperation < Operation

        def perform!(&block)
          remote_directory.files.create(
            key: key,
            body: File.open( resource.path ),
            multipart_chunk_size: 100.megabytes
          )
          FileUtils.rm_f resource.path if delete_source
          yield @options
        end

      end

      class DownloadOperation < Operation

        def perform!(&block)
          path = local_interactor.expand_path(resource.basename)
          @options[:path] = path
          file = remote_directory.files.get key
          File.open(path, "w") do |f|
            f.write(file.body)
          end
          file.destroy if delete_source
          yield @options
        end

      end

    end
  end
end
