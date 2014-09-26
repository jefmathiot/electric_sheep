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
        operation_opts=Struct.new(:host, :interactor, :file)
        from=operation_opts.new(
          resource.host,
          interactor_for(resource.host),
          resource
        )
        to=operation_opts.new(
          target_host=host(option(:to)),
          interactor_for(target_host),
          file_resource(target_host, resource.basename)
        )
        [DownloadOperation, UploadOperation].each do |op_klazz|
          op_klazz.new(from:from, to:to).perform(operation==:move) do |host, path|
            done! file_resource(host, path)
          end
        end
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

        def result(target,source, delete_source)
          if delete_source
            return to.host, target
          else
            return from.host, source
          end
        end

        def scp_cmd(target, cmd)
          @source=from.interactor.expand_path(from.file.path)
          @target=to.interactor.expand_path(to.file.path)
          target.interactor.scp.send(cmd, @source, @target)
        end

      end

      class UploadOperation < Operation

        def perform(delete_source, &block)
          return unless from.host.local? && !to.host.local?
          to.interactor.in_session do
            scp_cmd(to,:upload!)
          end
          from.interactor.in_session do
            from.interactor.exec("rm -f #{@source}") if delete_source
          end
          yield result(@target,@source, delete_source)
        end

      end

      class DownloadOperation < Operation

        def perform(delete_source, &block)
          return unless !from.host.local? && to.host.local?
          from.interactor.in_session do
            scp_cmd(from,:download!)
            from.interactor.exec("rm -f #{@source}") if delete_source
          end
          yield result(@target,@source, delete_source)
        end

      end

    end
  end
end
