module ElectricSheep
  module Commands
    module Compression
      class TarGz
        include ElectricSheep::Command
        include Helpers::ShellSafe
        include DeleteSource

        register as: 'tar_gz'

        option :tar_options

        def perform!
          logger.info "Compressing #{input.path} to #{input.basename}.tar.gz"
          input_path = shell.expand_path(input.path)
          file_resource(host, extension: '.tar.gz').tap do |archive|
            compress!(input_path, archive)
          end
        end

        private

        def compress!(input_path, archive)
          shell.exec cmd(input_path, archive)
          delete_source! input_path
        end

        def cmd(input_path, archive)
          cmd = "cd #{File.dirname(input_path)}; "
          cmd << " tar "
          cmd << option(:tar_options) unless option(:tar_options).nil?
          cmd << " -cvzf #{shell.expand_path(archive.path)} "
          cmd << "#{File.basename(input_path)} 1>&2"
        end
      end
    end
  end
end
