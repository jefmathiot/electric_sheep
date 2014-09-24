require 'session'

module ElectricSheep
  module Shell
    class LocalShell < Base
      include Helpers::Resourceful

      def initialize(localhost, project, logger)
        @host=localhost
        @logger = logger
        @project=project
      end

      def local?
        true
      end

      def remote?
        false
      end

      def open!
        return self if opened?
        @logger.info "Starting a local shell session"
        @interactor = Interactors::ShellInteractor.new
        @interactor.session
        self
      end

      def close!
        @session = nil
        self
      end

    end
  end
end
