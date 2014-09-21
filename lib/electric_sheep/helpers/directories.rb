require 'shellwords'
require 'fileutils'

module ElectricSheep
  module Helpers
    class Directories

      class << self

        def working_directory(host)
          host.working_directory || '$HOME/.electric_sheep'
        end


        def project_directory(host, project)
          File.join(
            working_directory(host),
            Shellwords.escape(project.id.downcase)
          )
        end

      end

    end
  end
end
