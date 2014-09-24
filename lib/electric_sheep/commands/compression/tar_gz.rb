module ElectricSheep
  module Commands
    module Compression
      class TarGz
        include ElectricSheep::Command
        include ElectricSheep::Helpers::Named

        register as: "tar_gz"

        option :delete_source

        def perform
          logger.info "Compressing #{resource.path} to #{resource.basename}.tar.gz"
          archive = with_named_file(
            shell.project_directory,
            resource.basename,
            extension:"tar.gz"
          ) do |file|
            shell.exec "tar -cvzf \"#{file}\" \"#{resource.path}\" &> /dev/null"
            shell.exec "rm -f \"#{shell.expand_path(resource.path)}\"" if option(:delete_source)
          end
          done! shell.file_resource(shell.host, archive)
        end

      end
    end
  end
end
