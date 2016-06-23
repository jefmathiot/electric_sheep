module ElectricSheep
  module Shell
    class Base
      include Helpers::ShellSafe

      alias safe shell_safe
      delegate :expand_path, :exec, to: :interactor
      delegate :stat_file, :stat_directory, :stat_filesystem, to: :interactor

      attr_reader :interactor, :host, :input

      def initialize(host, job, input, logger)
        @host = host
        @job = job
        @input = input
        @logger = logger
      end

      def perform!(metadata)
        interactor.in_session do
          metadata.pipelined(input, @job) do |cmd_metadata, cmd_input|
            klazz = cmd_metadata.agent_klazz
            command = klazz.new(@job, @logger, self, cmd_input, cmd_metadata)
            cmd_metadata.monitored do
              command.run!
            end
          end
        end
      end

      def local?
        @host.local?
      end

      def remote?
        !@host.local?
      end
    end
  end
end
