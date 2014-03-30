module ElectricSheeps
  module Commands
    module Compression
      class TarGz
        include Command
        include Helpers::Named

        register as: "tar_gz", of_type: :command
        resource :file, kind_of: Resources::File
        resource :directory, kind_of: Resources::Directory

        def perform
          target = file || directory
          logger.info "Compressing #{target.path} to #{target.basename}.tar.gz"
          archive = with_named_file work_dir, "#{target.basename}.tar.gz" do |file|
            shell.exec "tar -cvzf \"#{file}\" \"#{target.path}\""
          end
          done! Resources::File.new(path: archive, remote: shell.remote?)
        end

      end
    end
  end
end
