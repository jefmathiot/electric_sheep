require 'electric_sheep/ssh'
require 'net/scp'

module ElectricSheep
  module Transports
    class SCP
      include Transport
      include SSH

      register as: "scp"

      def copy
        to=option(:to)
        logger.info "Will copy #{resource.basename} " +
          "from #{resource.host.to_s} " +
          "to #{to.to_s}"
        remote_to_local(resource, to) if to.local?
      end

      def move
        from, to = resolve_hosts(resource)
        logger.info "Will move #{resource.basename} " +
          "from #{from.to_s} " +
          "to #{to.to_s}"
      end

      private
      def remote_to_local(resource, to)
        ssh_session resource.host, option(:as), @project.private_key do |ssh|
            ssh.scp.download! resource.path, "/tmp/#{resource.basename}"
        end
        done! Resources::File.new( "/tmp/#{resource.basename}")
      end

    end
  end
end
