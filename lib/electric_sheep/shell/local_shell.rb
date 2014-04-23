require 'session'
require 'shellwords'

module ElectricSheep
  module Shell
    class LocalShell
      include Directories
      include Resourceful

      def initialize(logger)
        @logger = logger
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

    end
  end
end
