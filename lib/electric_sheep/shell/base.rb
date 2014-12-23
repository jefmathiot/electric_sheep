module ElectricSheep
  module Shell
    class Base

      delegate :expand_path, :exec, to: :interactor
      delegate :stat_file, :stat_directory, :stat_filesystem, to: :interactor

      attr_reader :interactor, :host, :input

      def initialize(host, project, input, logger)
        @host = host
        @project=project
        @input=input
        @logger = logger
      end

      def perform!(metadata)
        interactor.in_session do
          metadata.pipelined(input) do |cmd_metadata, cmd_input|
            command=cmd_metadata.agent.new(@project, @logger, self, cmd_input,
              cmd_metadata )
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
