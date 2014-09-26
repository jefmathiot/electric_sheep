module ElectricSheep
  module Commands
    module Compression
      class TarGz
        include ElectricSheep::Command
        include Helpers::ShellSafe

        register as: "tar_gz"

        option :delete_source

        def perform
          logger.info "Compressing #{resource.path} to #{resource.basename}.tar.gz"
          archive=shell.expand_path(shell_safe("#{resource.basename}.tar.gz"))
          safe_resource=shell.expand_path(shell_safe(resource.path))
          shell.exec "tar -cvzf \"#{archive}\" \"#{safe_resource}\" &> /dev/null"
          shell.exec "rm -f \"#{safe_resource}\"" if option(:delete_source)
          done! shell.file_resource(shell.host, archive)
        end

      end
    end
  end
end
