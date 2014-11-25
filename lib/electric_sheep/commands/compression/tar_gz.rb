module ElectricSheep
  module Commands
    module Compression
      class TarGz
        include ElectricSheep::Command
        include Helpers::ShellSafe

        register as: "tar_gz"

        option :delete_source

        def run!
          logger.info "Compressing #{input.path} to #{input.basename}.tar.gz"
          input_path=shell.expand_path(input.path)
          done!(
            file_resource(extension: '.tar.gz').tap do |archive|
              shell.exec cmd(input_path, archive)
              shell.exec "rm -rf #{input_path}" if option(:delete_source)
            end
          )
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
