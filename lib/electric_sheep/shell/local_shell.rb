require 'session'

module ElectricSheep
  module Shell
    class LocalShell < Base
      def perform!(metadata)
        @logger.info 'Starting a local shell session'
        super
      end

      protected

      def interactor
        @interactor ||= Interactors::ShellInteractor.new(
          @host,
          @job,
          @logger
        )
      end
    end
  end
end
