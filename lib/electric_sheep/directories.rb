require 'shellwords'
require 'fileutils'

module ElectricSheep
  module Directories

    def mk_project_dir!(project)
      exec("mkdir -p #{project_dir(project)} ; chmod 0700 #{project_dir(project)}")
    end

    def project_dir(project)
      File.join work_dir, Shellwords.escape(project.id.downcase)
    end

    private
    def work_dir
      @work_dir ||= exec('echo ${ELECTRIC_SHEEP_HOME-"$HOME/.electric_sheep"}')[:out].chomp
    end

  end
end
