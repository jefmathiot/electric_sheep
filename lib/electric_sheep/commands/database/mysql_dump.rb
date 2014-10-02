module ElectricSheep
  module Commands
    module Database
      class MySQLDump
        include Command
        include Helpers::Timestamps
        include Helpers::ShellSafe

        register as: "mysql_dump"

        option :user
        option :password

        def perform
          logger.info "Creating a dump of the \"#{resource.name}\" MySQL database"
          dump=shell.expand_path("#{resource.name}-#{timestamp}")
          shell.exec "#{cmd(resource.name, option(:user), option(:password), dump)}"
          done! shell.file_resource(shell.host, dump)
        end

        private
        def cmd(db, user, password, output)
          cmd = "mysqldump"
          cmd << " --user=#{shell_safe(user)} --password=#{shell_safe(password)}" unless user.nil?
          cmd << " #{shell_safe(db)} > #{output}"
        end
      end
    end
  end
end
