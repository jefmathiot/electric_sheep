require 'net/scp'


module ElectricSheep
  module Transports
    class SCP
      include Transport
      include Helpers::Resourceful

      register as: "scp"

      def copy
        operate :copy
      end

      def move
        operate :move
      end

      private
      def interactor_for(host)
        if host.local?
          local_interactor
        else
          Interactors::SshInteractor.new(host, @project, option(:as))
        end
      end

      def operate(operation)
        operation_opts=Struct.new(:resource, :interactor)
        from=operation_opts.new(
          resource,
          interactor_for(resource.host)
        )
        target_host=host(option(:to))
        to=operation_opts.new(
          build_resource(resource.directory?, target_host, resource.basename),
          interactor_for(target_host)
        )
        [DownloadOperation, UploadOperation].each do |op_klazz|
          delete_source=operation==:move
          op_klazz.new(from: from, to: to).perform(delete_source) do |host, path|
            done! build_resource(resource.directory?, option(:to), path)
          end
        end
      end

      def build_resource(directory, host, path)
        send("#{directory ? :directory : :file}_resource", host, path)
      end

      class Operation

        def initialize(options)
          @options=options
        end

        def from
          @options[:from]
        end

        def to
          @options[:to]
        end

        def result(target, source, delete_source)
          if delete_source
            return to.resource.host, target
          else
            return from.resource.host, source
          end
        end

        def copy(target, action)
          @source_path=from.interactor.expand_path(from.resource.path)
          @target_path=to.interactor.expand_path(to.resource.path)
          # TODO Allow the target directory name to be changed
          # Recursive creates a target directory then copies the source directory in it.
          # We end up with two nested directories of the same name.
          # See http://net-ssh.github.io/net-scp/classes/Net/SCP.html#method-i-download-21
          @target_path=File.dirname(@target_path) if from.resource.directory?
          target.interactor.scp.send(
            "#{action}!",
            @source_path,
            @target_path,
            recursive: from.resource.directory?
          )
        end

        def delete_cmd
          "rm -rf #{@source_path}"
        end

      end

      class UploadOperation < Operation

        def perform(delete_source, &block)
          return unless from.resource.host.local? && !to.resource.host.local?
          to.interactor.in_session do
            copy(to, :upload)
          end
          from.interactor.in_session do
            from.interactor.exec(delete_cmd) if delete_source
          end
          yield result(@target_path, @source_path, delete_source)
        end

      end

      class DownloadOperation < Operation

        def perform(delete_source, &block)
          return unless !from.resource.host.local? && to.resource.host.local?
          from.interactor.in_session do
            copy(from, :download)
            from.interactor.exec(delete_cmd) if delete_source
          end
          yield result(@target_path, @source_path, delete_source)
        end

      end

    end
  end
end
