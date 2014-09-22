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
        to=option(:to)
        logger.info "Will copy #{resource.basename} " +
          "from #{resource.host.to_s} " +
          "to #{to.to_s}"
        remote_to_local(to) if to.local?
      end

      def move
        to=option(:to)
        logger.info "Will move #{resource.basename} " +
          "from #{resource.host.to_s} " +
          "to #{to.to_s}"
        remote_to_local(to, true) if to.local?
      end

      private
      def remote_to_local(to, move=false)
        directory = Helpers::Directories::project_directory(to, @project)
        FileUtils.mkdir_p directory
        path = with_named_path directory, resource.basename do |output|
          in_remote_session resource.host do |ssh|
            ssh.scp.download! resource.path, output, verbose: true
            ssh_exec ssh, "rm -f #{resource.path}" if move
          end
        end
        done! file_resource( to, path )
      end

    end
  end
end
