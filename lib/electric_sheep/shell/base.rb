module ElectricSheep
  module Shell
    class Base

      delegate :expand_path, :exec, to: :interactor

      attr_reader :interactor, :host

      def initialize(host, project, logger)
        @host = host
        @project=project
        @logger = logger
      end

      def perform!(metadata)
        interactor.in_session do
          metadata.each_item do |cmd_metadata|
            command=cmd_metadata.agent.new(@project, @logger, self, cmd_metadata )
            cmd_metadata.benchmarked do
              command.check_prerequisites
              command.perform
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
