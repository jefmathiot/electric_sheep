module ElectricSheep
  module Interactors
    class ShellInteractor < Base
      include ShellStat

      def exec(cmd)
        @logger.debug cmd if @logger
        after_exec do
          Spawn.exec(cmd, @logger)
        end
      end

      protected
      def build_session ; end

    end
  end
end
