require 'session'

module ElectricSheep
  module Shell
    class LocalShell
      include Directories
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
        @session = ::Session::Sh.new
        self
      end

      def close!
        @session = nil
        self
      end

      def exec(cmd)
        raise "Shell not opened" unless opened?
        {out: '', err: ''}.tap{ |result|
          @session.execute(cmd) do |out, err|
            @logger.info( result[:out] = out.chomp ) unless out.nil?
            @logger.error( result[:err] = err.chomp ) unless err.nil?
          end
        }.merge({exit_status: @session.exit_status})
      end

      def opened?
        !@session.nil?
      end

      def parse_env_variable(string)
        exec("echo #{string}")[:out]
      end
    end
  end
end
