module ElectricSheep
  module Commands
    module Database
      class MySQLDump
        include ElectricSheep::Command
        include ElectricSheep::Helpers::Named

        register as: "mysql_dump"

        option :user
        option :password

        def perform
          logger.info "Creating a dump of the \"#{resource.name}\" MySQL database"
          dump = with_named_file(
            shell.project_directory,
            resource.name,
            timestamp: true,
            extension: 'sql'
          ) do |output|
            shell.exec "#{cmd(resource.name, option(:user), option(:password), output)}"
          end
          done! shell.file_resource(shell.host, dump)
        end

        private
        def cmd(db, user, password, output)
          cmd = "mysqldump"
          cmd << " --user=\"#{shell_safe(user)}\" --password=\"#{shell_safe(password)}\"" unless user.nil?
          cmd << " \"#{shell_safe(db)}\" > \"#{output}\""
        end
      end
    end
  end
end
