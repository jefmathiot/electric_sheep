require 'pathname'
require 'fileutils'

module ElectricSheep
  module Helpers
    class Directories
      include ShellSafe

      def initialize(host, job, interactor)
        @host=host
        @job=job
        @interactor=interactor
      end

      def mk_job_directory!
        @interactor.exec(
          "mkdir -p \"#{job_directory}\" ; chmod 0700 \"#{job_directory}\""
        )
      end

      def expand_path(path)
        raise "job directory has not been created, please" +
          " call mk_job_directory!" unless @job_directory
        return path if Pathname.new(path).absolute?
        File.join(job_directory, shell_safe(path))
      end

      private

      def working_directory
        @host.working_directory || "$HOME/.electric_sheep"
      end

      def job_directory
        unless @job_directory
          directory=File.join(
            working_directory,
            shell_safe(@job.id.downcase)
          )
          @job_directory=@interactor.exec("echo \"#{directory}\"")[:out]
        end
        @job_directory
      end

    end
  end
end
