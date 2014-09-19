require 'net/ssh'
require 'net/scp'

module ElectricSheep
  module Transports
    class SCP
      include ElectricSheep::Transport

      register as: "scp"

      def copy
        from, to = resolve_hosts(resource)
        logger.info "Will copy #{resource.basename} " +
          "from #{from.to_s} " +
          "to #{to.to_s}"
        remote_to_local(from, to, resource) if to.local?
      end

      def move
        from, to = resolve_hosts(resource)
        logger.info "Will move #{resource.basename} " +
          "from #{from.to_s} " +
          "to #{to.to_s}"
      end

      private
      def resolve_hosts(resource)
        return resource.host, option(:to)
      end

      def remote_to_local(from, to, resource)
        Net::SSH.start(from.hostname, option(:as),
          port: from.ssh_port,
          key_data: Crypto.get_key(@project.private_key, :private).export,
          keys_only: true) do |ssh|
            ssh.scp.download! resource.path, "/tmp/#{resource.basename}"
        end
        done! Resources::File.new( "/tmp/#{resource.basename}")
      end

    end
  end
end
