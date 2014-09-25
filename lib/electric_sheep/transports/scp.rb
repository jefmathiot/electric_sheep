require 'net/scp'


module ElectricSheep
  module Transports
    class SCP
      include Transport
      include Helpers::Resourceful

      register as: "scp"

      def copy
        operate :copy
        done! @origin_file
      end

      def move
        operate :move
        done! @target_file
      end

      private
      def interactor_for(host)
        if host.local?
          local_interactor
        else
          Interactors::SshInteractor.new(host, option(:as), @project)
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
          op_klazz.new(from, to).perform(operation==:move) do |host, path|
            done! file_resource(host, path)
          end
        end
      end

      class Operation

        def initialize(options)
          @options=options
        end

        def from
          options[:from]
        end

        def to
          options[:to]
        end

        def result(target,source, delete_source)
          if delete_source
            return to.host, target
          else
            return from.host, source
          end
        end

      end

      class UploadOperation < Operation

        def perform(delete_source, &block)
          # TODO Also check the to is a remote host
          return unless from.host.local?
          to.interactor.in_session do
            #mk_project_directory(to.host, to.interactor)
            source=from.interactor.expand_path(from.file.path)
            target=to.interactor.expand_path(to.file.path)
            to.interactor.upload!( source, target)
          end
          from.interactor.in_session do
            from.interactor.exec("rm -f #{source}") if delete_source
          end
          yield result(target,source, delete_source)
        end

      end

      class DownloadOperation < Operation

        def perform(delete_source, &block)
          # TODO Also check the from is a remote host
          return if from.host.local?
          from.interactor.in_session do
            source=from.interactor.expand_path(from.file.path)
            target=to.interactor.expand_path(to.file.path)
            to.interactor.download!( source, target)
            from.interactor.exec("rm -f #{source}") if delete_source
          end
          yield result(target,source, delete_source)
        end

      end

      # def ensure_scp_performable
      #   raise "scp transfert should have at least one remote host !" if @origin_host.local? && @target_host.local?
      # end

      # def copy_origin_to_host
      #   send('copy_from_'+host_type(@origin_file.host))
      # end

      # def ensure_target_folder_exist
      #   @target_shell.mk_project_directory!
      # end

      # def log_info(function)
      #   logger.info "Will #{function} #{@origin_file.basename} " +
      #     "from #{@origin_file.host.to_s} " +
      #     "to #{@target_file.host.to_s} using SCP"
      # end

      # def host_type(host)
      #   host.local? ? 'local' : 'remote'
      # end

      # def copy_from_remote
      #   if @target_file.host.local?
      #     copy_with_scp_cmd(:download!,@origin_shell)
      #   else
      #     raise "remote to remote not implemented"
      #   end
      # end

      # def copy_from_local
      #   copy_with_scp_cmd(:upload!,@target_shell)
      # end

      # def copy_with_scp_cmd(cmd,shell)
      #   origin_file_path = @origin_shell.expand_path(@origin_file.path)
      #   target_file_path = @target_shell.expand_path(@target_file.path)
      #   shell.session.scp.send(cmd, origin_file_path, target_file_path, verbose: true)
      # end

      # def delete_origin
      #   origin_file_path = @origin_shell.expand_path(@origin_file.path)
      #   @origin_shell.exec "rm -f #{origin_file_path}"
      # end

    end
  end
end
