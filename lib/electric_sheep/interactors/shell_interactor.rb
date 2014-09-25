module ElectricSheep
  module Interactors
    class ShellInteractor < Base

      def exec(cmd, logger=nil)
        {out: '', err: ''}.tap{ |result|
          session.execute(cmd) do |out, err|
            unless out.nil?
              result[:out] = out.chomp
              logger.info( result[:out] ) if logger
            end
            unless err.nil?
              result[:err] = err.chomp
              logger.error( result[:err] ) if logger
            end
          end
        }.merge({exit_status: session.exit_status})
      end

      protected
      def build_session
        ::Session::Sh.new
      end

    end
  end
end
