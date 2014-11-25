module ElectricSheep
  module Commands
    module Database
      class MySQLDump
        include Command
        include Helpers::ShellSafe

        register as: "mysql_dump"

        option :user
        option :password

        def run!
          logger.info "Creating a dump of the \"#{input.basename}\" MySQL database"
          done!(
            file_resource(extension: '.sql').tap do |dump|
              shell.exec cmd(input.name, option(:user), option(:password), dump)
            end
          )
        end

        private
        def cmd(db, user, password, dump)
          cmd = "mysqldump"
          cmd << " --user=#{shell_safe(user)} --password=#{shell_safe(password)}" unless user.nil?
          cmd << " #{shell_safe(db)} > #{shell.expand_path(dump.path)}"
        end
      end
    end
  end
end
