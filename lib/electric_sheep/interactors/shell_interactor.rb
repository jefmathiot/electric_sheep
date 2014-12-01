module ElectricSheep
  module Interactors
    class ShellInteractor < Base
      include Helpers::ShellStat

      def exec(cmd)
        @logger.debug cmd if @logger
        after_exec do
          {out: '', err: ''}.tap{ |result|
            session.execute(cmd) do |out, err|
              unless out.nil?
                result[:out] = out.chomp
                @logger.debug result[:out] if @logger
              end
              unless err.nil?
                result[:err] = err.chomp
              end
            end
          }.merge({exit_status: session.exit_status})
        end
      end

      protected
      def build_session
        ::Session::Sh.new
      end

    end
  end
end
