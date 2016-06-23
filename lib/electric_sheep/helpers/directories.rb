require 'pathname'
require 'fileutils'

module ElectricSheep
  module Helpers
    class Directories
      include ShellSafe

      def initialize(host, job, interactor)
        @host = host
        @job = job
        @interactor = interactor
      end

      def mk_job_directory!
        safe = shell_safe(job_directory)
        @interactor
          .exec "mkdir -p #{safe} ; chmod 0700 #{safe}"
      end

      def expand_path(path)
        raise 'job directory has not been created, please' \
              ' call mk_job_directory!' unless @job_directory
        return path if Pathname.new(path).absolute?
        File.join(job_directory, path)
      end

      private

      def working_directory
        @host.working_directory || '$HOME/.electric_sheep'
      end

      def job_directory
        unless @job_directory
          directory = FSUtil.expand_path(@interactor, working_directory)
          @job_directory = File.join(directory, @job.id.downcase)
        end
        @job_directory
      end
    end
  end
end
