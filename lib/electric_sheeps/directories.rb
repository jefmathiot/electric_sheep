require 'shellwords'
require 'fileutils'

module ElectricSheeps
  class Directories

    class << self

      def mk_work_dir!
        mk_dir!(work_dir)
      end

      def mk_project_dir!(project)
        mk_work_dir!
        project_dir(project).tap do |dir|
          mk_dir! dir
        end
      end

      def work_dir
        @work_dir ||= ENV['ELECTRIC_SHEEPS_HOME'] || "#{user_home}/.electric_sheeps"
      end

      def project_dir(project)
        File.join work_dir, Shellwords.escape(project.id.downcase)
      end

      private
      def mk_dir!(directory)
        FileUtils.mkdir_p(directory, mode: 0700) unless File.directory?(directory)
      end

      def user_home
         ENV['HOME']
      end

    end

  end
end
