module ElectricSheep
  module Interactors
    require 'posix/spawn'
    class ShellInteractor < Base
      include ShellStat

      def exec(cmd)
        @logger.debug cmd if @logger
        after_exec do
          {out: '', err: ''}.tap{ |result|
            @child = POSIX::Spawn::Child.new(cmd)
            unless @child.out.nil?
              result[:out] = @child.out.chomp
              @logger.debug result[:out] if @logger
            end
            unless @child.err.nil?
              result[:err] = @child.err.chomp
            end

          }.merge({exit_status: @child.status})
        end
      end

      protected
      def build_session
        true
      end

    end
  end
end
