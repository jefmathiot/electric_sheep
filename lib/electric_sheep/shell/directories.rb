module ElectricSheep
  module Shell
    module Directories
      def mk_project_directory!
        project_directory.tap do |directory|
          exec("mkdir -p #{directory} ; chmod 0700 #{directory}")
        end
      end

      def project_directory
        Helpers::Directories.project_directory(@host, @project)
      end
    end
  end
end
