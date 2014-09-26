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
          archive=shell.expand_path(shell_safe("#{resource.path}.tar.gz"))
          shell.exec "tar -cvzf \"#{archive}\" \"#{resource.path}\" &> /dev/null"
          shell.exec "rm -f \"#{shell.expand_path(shell_safe(resource.path))}\"" if option(:delete_source)
          done! shell.file_resource(shell.host, archive)
        end

      end
    end
  end
end
