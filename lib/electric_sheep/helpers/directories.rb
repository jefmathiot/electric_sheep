require 'fileutils'

module ElectricSheep
  module Helpers
    class Directories
      include ShellSafe

      def initialize(host, project, interactor)
        @host=host
        @project=project
        @interactor=interactor
      end

      def mk_project_directory!
        @interactor.exec(
          "mkdir -p #{project_directory} ; chmod 0700 #{project_directory}"
        )[:out]
      end

      def expand_path(path)
        raise "Project directory has not been created, please" +
          "call mk_project_directory!" unless @project_directory
        return path if Pathname.new(path).absolute?
        File.join(project_directory, shell_safe(path))
      end

      private

      def working_directory
        @host.working_directory || "$HOME/.electric_sheep"
      end

      def project_directory
        unless @project_directory
          directory=File.join(
            working_directory,
            shell_safe(@project.id.downcase)
          )
          @project_directory=@interactor.exec("echo \"#{directory}\"")[:out]
        end
        @project_directory
      end

    end
  end
end
