module ElectricSheep
  module Commands
    module Compression
      class TarGz
        include Command
        include Helpers::Named

        register as: "tar_gz", of_type: :command

        def perform
          logger.info "Compressing #{resource.path} to #{resource.basename}.tar.gz"
          archive = with_named_file work_dir, "#{resource.basename}.tar.gz" do |file|
            shell.exec "tar -cvzf \"#{file}\" \"#{resource.path}\" &> /dev/null"
          end
          done! Resources::File.new(path: archive, remote: shell.remote?)
        end

      end
    end
  end
end
