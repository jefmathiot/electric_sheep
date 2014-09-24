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

      def operate(function)
        @origin_host = resource.host
        @target_host = host(option(:to))
        @origin_file = resource
        @target_file = file_resource( @target_host, target_file_path )
        logger.info @origin_file.inspect
        logger.info @target_file.inspect
        log_info function
        ensure_scp_performable
        in_remote_session remote_host do |ssh|
          @ssh = ssh
          ensure_target_folder_exist
          copy_origin_to_host(@origin_file, @target_file)
          delete_origin if function == :move
        end
      end

      def remote_host
        @origin_host.local? ? @target_host : @origin_host
      end

      def ensure_scp_performable
        raise "scp transfert should have at least one remote host !" if @origin_host.local? && @target_host.local?
      end

      def copy_origin_to_host(origin_file, target_file)
        send('copy_from_'+host_type(origin_file.host),origin_file, target_file)
      end

      def target_file_path
        with_named_path(project_folder(@target_host),@origin_file.basename)
      end

      def project_folder(target_host)
        Helpers::Directories::project_directory(target_host, @project)
      end

      def ensure_target_folder_exist
        send('ensure_folder_'+host_type(@target_host))
      end

      def log_info(function)
        logger.info "Will #{function} #{@origin_file.basename} " +
          "from #{@origin_file.host.to_s} " +
          "to #{@target_file.host.to_s} using SCP"
      end

      def host_type(host)
        host.local? ? 'local' : 'remote'
      end

      def ensure_folder_remote
        ssh_exec @ssh, "mkdir -p #{project_folder(@target_host)}"
      end

      def ensure_folder_local
        FileUtils.mkdir_p project_folder(@target_host)
      end

      def copy_from_remote(origin_file, target_file)
        if target_file.host.local?
          scp_transfert(:download!, origin_file, target_file)
        else
          raise "remote to remote not implemented"
        end
      end

      def copy_from_local(origin_file, target_file)
        scp_transfert(:upload!, origin_file, target_file)
      end

      def scp_transfert(type, origin_file, target_file)
        origin_file_path = path_without_env_variable origin_file
        target_file_path = path_without_env_variable target_file
        logger.info origin_file_path, target_file_path
        @ssh.scp.send(type, origin_file_path, target_file_path, verbose: true)
      end

      # def path_without_env_variable(file)
      #   if file.host.local?
      #     `echo #{file.host.working_directory}`.strip
      #   else
      #     ssh_exec(@ssh, "echo #{file.host.working_directory}")[:out]
      #   end
      # end

      def path_without_env_variable(file)
        if file.host.local?
          `echo #{file.path}`.strip
        else
          ssh_exec(@ssh, "echo #{file.path}")[:out]
        end
      end

      def delete_origin
        origin_file_path = path_without_env_variable @origin_file
        if(@origin_file.host.local?)
          FileUtils.rm_f origin_file_path
        else
          ssh_exec @ssh, "rm -f #{origin_file_path}"
        end
      end

    end
  end
end
