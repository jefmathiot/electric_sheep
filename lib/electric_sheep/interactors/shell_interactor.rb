module ElectricSheep
  module Interactors
    class ShellInteractor < Base
      include ShellStat

      def exec(*cmd)
        _exec(*cmd) do |cmd_as_string|
          Spawn.exec(cmd_as_string, @logger)
        end
      end

      protected

      def build_session; end
    end
  end
end
