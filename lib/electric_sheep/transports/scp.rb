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

      def shell_for(host, project)
        if(host.local?)
          Shell::LocalShell.new(host,@project,@logger).open!
        else
          Shell::RemoteShell.new(@logger,host,option(:as),@project).open!
        end
      end

      def operate(function)
        @origin_host = resource.host
        @origin_shell= shell_for(@origin_host,@project)
        @origin_file = resource

        @target_host = host(option(:to))
        @target_shell= shell_for(@target_host,@project)
        @target_file = file_resource( @target_host, target_file_path )


        log_info function
        ensure_scp_performable
        ensure_target_folder_exist
        copy_origin_to_host
        delete_origin if function == :move
        @origin_shell.close!
        @target_shell.close!
      end

      def ensure_scp_performable
        raise "scp transfert should have at least one remote host !" if @origin_host.local? && @target_host.local?
      end

      def copy_origin_to_host
        send('copy_from_'+host_type(@origin_file.host))
      end

      def target_file_path
        @target_shell.expand_path(@origin_file.basename)
      end

      def ensure_target_folder_exist
        @target_shell.mk_project_directory!
      end

      def log_info(function)
        logger.info "Will #{function} #{@origin_file.basename} " +
          "from #{@origin_file.host.to_s} " +
          "to #{@target_file.host.to_s} using SCP"
      end

      def host_type(host)
        host.local? ? 'local' : 'remote'
      end

      def copy_from_remote
        if @target_file.host.local?
          copy_with_scp_cmd(:download!,@origin_shell)
        else
          raise "remote to remote not implemented"
        end
      end

      def copy_from_local
        copy_with_scp_cmd(:upload!,@target_shell)
      end

      def copy_with_scp_cmd(cmd,shell)
        origin_file_path = @origin_shell.expand_path(@origin_file.path)
        target_file_path = @target_shell.expand_path(@target_file.path)
        logger.info origin_file_path, target_file_path
        shell.session.scp.send(cmd, origin_file_path, target_file_path, verbose: true)
      end

      def delete_origin
        origin_file_path = @origin_shell.expand_path(@origin_file.path)
        @origin_shell.exec "rm -f #{origin_file_path}"
      end

    end
  end
end
