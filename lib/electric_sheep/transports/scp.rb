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
      end

      def move
        from, to = resolve_hosts(resource)
        logger.info "Will move #{resource.basename} " +
          "from #{from.to_s} " +
          "to #{to.to_s}"
      end

      private
      def resolve_hosts(resource)
        return resolve_host(resource.host), resolve_host(option(:to))
      end
    end
  end
end
