require 'session'
require 'shellwords'

module ElectricSheeps
    module Shell
        class LocalShell
            def initialize(logger)
                @logger = logger
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
                return unless opened?
                @session.execute(cmd) do |out, err|
                    @logger.info out.chomp unless out.nil?
                    @logger.error err.chomp unless err.nil?
                end
                @session.exit_status
            end

            def opened?
                !@session.nil?
            end

        end
    end
end