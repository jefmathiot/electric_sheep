require 'net/scp'

module ElectricSheep
  module Transports
    class SCP
      include Transport

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
        log(operation)
        operation_opts=Struct.new(:resource, :interactor)
        from=operation_opts.new(
          input,
          interactor_for(input.host)
        )
        target_host=host(option(:to))
        to=operation_opts.new(
          build_resource(target_host),
          interactor_for(target_host)
        )
        delete_source=operation==:move
        [DownloadOperation, UploadOperation].each do |op_klazz|
          op_klazz.new(from: from, to: to).perform(delete_source)
        end
        done! delete_source ? to.resource : from.resource
      end

      def build_resource(target_host)
        send("#{input.directory? ? :directory : :file}_resource", target_host)
      end

      class Operation

        def initialize(options)
          @options=options
        end

        protected
        def from
          @options[:from]
        end

        def to
          @options[:to]
        end

        def copy(target, action)
          send(
            from.resource.directory? ? :copy_directory : :copy_file,
            action,
            target.interactor
          )
        end

        def copy_file(action, interactor)
          interactor.scp.send(
            "#{action}!",
            paths[:source],
            paths[:target]
          )
        end

        def copy_directory(action, interactor)
          tmp_path=File.join(File.dirname(paths[:target]), tmpdir)
          # net-scp copy a new "source" directory inside the target one
          scp_path=File.join(tmp_path, File.basename(paths[:source]))
          to.interactor.exec "mkdir #{tmp_path}"
          interactor.scp.send(
            "#{action}!",
            paths[:source],
            tmp_path,
            recursive: true
          )
          to.interactor.exec "mv #{scp_path} #{paths[:target]}"
          to.interactor.exec "rm -rf #{tmp_path}"
        end

        def paths
          @paths ||= {
            source: from.interactor.expand_path(from.resource.path),
            target: to.interactor.expand_path(to.resource.path)
          }
        end

        def tmpdir
          t = Time.now.strftime("%Y%m%d")
          "tmp#{t}-#{$$}-#{rand(0x100000000).to_s(36)}"
        end

        def delete_cmd
          "rm -rf #{paths[:source]}"
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
        end

      end

      class DownloadOperation < Operation

        def perform(delete_source, &block)
          return unless !from.resource.host.local? && to.resource.host.local?
          from.interactor.in_session do
            copy(from, :download)
            from.interactor.exec(delete_cmd) if delete_source
          end
        end

      end

    end
  end
end
