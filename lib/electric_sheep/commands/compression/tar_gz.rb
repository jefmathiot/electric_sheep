module ElectricSheep
  module Commands
    module Compression
      class TarGz
        include ElectricSheep::Command
        include Helpers::ShellSafe
        include DeleteSource

        register as: "tar_gz"

        def perform!
          logger.info "Compressing #{input.path} to #{input.basename}.tar.gz"
          input_path=shell.expand_path(input.path)
          file_resource(host, extension: '.tar.gz').tap do |archive|
            shell.exec cmd(input_path, archive)
            delete_source!(input_path)
          end
        end

        private
        def cmd(input_path, archive)
          cmd = "cd #{File.dirname(input_path)}; "
          cmd << "tar -cvzf #{shell.expand_path(archive.path)} "
          cmd << "#{File.basename(input_path)} 1>&2"
        end
      end
    end
  end
end
