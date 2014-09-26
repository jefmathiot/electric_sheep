require 'session'

module ElectricSheep
  module Shell
    class LocalShell < Base

      def initialize(host, project, logger)
        super
      end

      def interactor
        @interactor ||= Interactors::ShellInteractor.new(
          @host, 
          @project, 
          @logger
        )
      end

      def perform!(metadata)
        @logger.info "Starting a local shell session"
        super
      end
    end
  end
end
