module ElectricSheep
  module Transports
    class SCP
      include ElectricSheep::Transport

      register as: "scp"

      def copy
        logger.info "Will copy #{resource.basename} " + 
          "from #{resource.host} " +
          "to #{option(:to).to_s}"  
      end

      def move
        logger.info "Will move #{resource.basename}" +
          "from #{resource.host} " +
          "to #{option(:to).to_s}"  
      end

    end
  end
end
