require 'net/scp'


module ElectricSheep
  module Transports
    class SCP
      include Transport
      include Helpers::SSH
      include Helpers::Named
      include Helpers::Resourceful

      register as: "scp"

      def copy
        operation
      end

      def move
        operation true
      end

      private

      def operation(delete_source=false)
        from=resource.host
        to=host(option(:to))
        logger.info "Will #{delete_source ? 'move' : 'copy'} #{resource.basename} " +
          "from #{resource.host.to_s} " +
          "to #{to.to_s} using SCP"
        send(direction_type(from,to),to,delete_source)
      end

      def remote_to_local(to, delete_source=false)
        destination_directory = Helpers::Directories::project_directory(to, @project)
        FileUtils.mkdir_p destination_directory
        path = with_named_path destination_directory, resource.basename do |destination_file|
          in_remote_session resource.host do |ssh|
            ssh.scp.download! resource.path, destination_file, verbose: true
            ssh_exec ssh, "rm -f #{resource.path}" if delete_source
          end
        end
        if delete_source
          done! file_resource( to, path )
        else
          done! resource
        end
      end

      def local_to_remote(to, delete_source=false)
        remote_directory = Helpers::Directories::project_directory(to, @project)
        resource_path = parse_local_env_variable
        path = with_named_path remote_directory, resource.basename do |output|
          in_remote_session to do |ssh|
            output = parse_remote_env_variable(ssh, output)
            ssh_exec ssh, "mkdir -p #{remote_directory}"
            ssh.scp.upload! resource.path, output, verbose: true
          end
          FileUtils.rm_f resource_path if delete_source
        end
        if delete_source
          done! file_resource( to, path )
        else
          done! resource
        end
      end

      def parse_local_env_variable
        shell.parse_env_variable(resource.path)
      end

      def parse_remote_env_variable(ssh,output)
        ssh_exec(ssh, "echo #{output}")[:out]
      end

      def remote_to_remote(to, delete_source=false)
        raise 'remote to remote not implemented'
      end

      def local_to_local(to, delete_source=false)
        raise 'local to local not implemented'
      end

      def direction_type(from, to)
        direction = ''
        direction << (from.local? ? 'local' : 'remote')
        direction << '_to_'
        direction << (to.local? ? 'local' : 'remote')
      end

    end
  end
end
