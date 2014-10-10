module ElectricSheep
  module Commands
    module Compression
      class TarGz
        include ElectricSheep::Command
        include Helpers::ShellSafe

        register as: "tar_gz"

        option :delete_source

        def perform
          logger.info "Compressing #{input.path} to #{input.basename}.tar.gz"
          input_path=shell.expand_path(input.path)
          done!(
            file_resource(extension: '.tar.gz').tap do |archive|
              shell.exec cmd(input_path, archive)
              shell.exec "rm -f #{input_path}" if option(:delete_source)
            end
          )
        end

        private
        def cmd(input_path, archive)
          "cd #{File.dirname(input_path)}; " +
            "tar -cvzf #{shell.expand_path(archive.path)} "+
            "#{File.basename(input_path)} &> /dev/null"
        end
      end
    end
  end
end
