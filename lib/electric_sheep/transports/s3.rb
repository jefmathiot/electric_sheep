require 'fog'

module ElectricSheep
  module Transports
    class S3
      include Transport

      register as: "s3"

      option :access_key_id, required: true
      option :secret_key, required: true

      def copy
        operate :copy
      end

      def move
        operate :move
      end

      protected
      def operate(operation)
        log(operation)
        delete_source = operation == :move
        perform(delete_source).perform! do |resource|
          done! delete_source ? resource : input
        end
      end

      def perform(delete_source)
        if option(:to)=='localhost'
          output=file_resource host(option(:to))
          return DownloadOperation.new(
            connection,
            input,
            output,
            delete_source,
            local_interactor
          )
        else
          with_directory do |bucket, prefix|
            output=s3_resource(bucket, prefix).tap do |output|
              return UploadOperation.new(
                connection,
                input,
                output,
                delete_source,
                local_interactor
              )
            end
          end
        end
      end

      def s3_resource(bucket, prefix, options={})
        Resources::S3Object.new(
          options.merge(
            bucket: bucket,
            parent: prefix,
            basename: input.basename,
            extension: input.extension
          )
        ).tap do |resource|
          resource.timestamp!(input)
        end
      end

      def with_directory(&block)
        option(:to).split('/').tap do |paths|
          bucket = paths.shift
          yield bucket, paths.length > 0 ? paths.join('/') : nil
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

      class Operation
        attr_reader :connection, :input, :output, :delete_source, :interactor
        def initialize(connection, input, output, delete_source, interactor)
          @connection=connection
          @input=input
          @output=output
          @delete_source=delete_source
          @interactor=interactor
        end

        def remote_directory(bucket)
          connection.directories.get(bucket)
        end

        protected
        def key(resource)
          resource.path
        end
      end

      class UploadOperation < Operation

        def perform!(&block)
          remote_directory(output.bucket).files.create(
            key: output.path,
            body: File.open( interactor.expand_path(input.path) ),
            multipart_chunk_size: 100.megabytes
          )
          FileUtils.rm_f input.path if delete_source
          yield output
        end

      end

      class DownloadOperation < Operation

        def perform!(&block)
          path = interactor.expand_path(output.path)
          # TODO Handle large files ?
          file = remote_directory(input.bucket).files.get input.path
          File.open(path, "w") do |f|
            f.write(file.body)
          end
          file.destroy if delete_source
          yield output
        end

      end

    end
  end
end
