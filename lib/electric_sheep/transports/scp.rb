require 'electric_sheep/helpers/ssh'
require 'net/scp'

module ElectricSheep
  module Transports
    class SCP
      include Transport
      include Directories
      include Helpers::SSH
      include Helpers::Named
      include Helpers::Resourceful

      register as: "scp"

      def copy
        to=option(:to)
        logger.info "Will copy #{resource.basename} " +
          "from #{resource.host.to_s} " +
          "to #{to.to_s}"
        remote_to_local if to.local?
      end

      def move
        from, to = resolve_hosts(resource)
        logger.info "Will move #{resource.basename} " +
          "from #{from.to_s} " +
          "to #{to.to_s}"
      end

      private
      def remote_to_local
        path = with_named_path work_dir, resource.name do |output| 
          in_session resource.host do |ssh|
              ssh.scp.download! resource.path, output
          end
        end
        done! file_resource( path )
      end

      def in_session(host, &block)
        ssh_session host, option(:as), @project.private_key do |ssh|
          block.call ssh
        end
      end

    end
  end
end
