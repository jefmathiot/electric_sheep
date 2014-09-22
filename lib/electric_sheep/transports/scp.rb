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
        directory = Helpers::Directories::project_directory(to, @project)
        FileUtils.mkdir_p directory
        path = with_named_path directory, resource.basename do |output|
          in_remote_session resource.host do |ssh|
            ssh.scp.download! resource.path, output, verbose: true
            ssh_exec ssh, "rm -f #{resource.path}" if delete_source
          end
        end
        done! file_resource( to, path )
      end

      def local_to_remote(to, delete_source=false)
        directory = Helpers::Directories::project_directory(to, @project)
        path = with_named_path directory, resource.basename do |output|
          in_remote_session to do |ssh|
            ssh_exec ssh, "mkdir -p #{directory}"
            ssh.scp.upload! resource.path, output, verbose: true
          end
          FileUtils.rm_f resource.path if delete_source
        end
        done! file_resource( to, path )
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
