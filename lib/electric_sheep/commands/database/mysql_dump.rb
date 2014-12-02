module ElectricSheep
  module Commands
    module Database
      class MySQLDump
        include Command
        include Helpers::ShellSafe

        register as: "mysql_dump"

        option :user
        option :password

        def perform!
          logger.info "Creating a dump of the \"#{input.basename}\" MySQL database"
          done!(
            file_resource(host, extension: '.sql').tap do |dump|
              shell.exec cmd(input.name, option(:user), option(:password), dump)
            end
          )
        end

        def stat_database(input)
          cmd=database_size_cmd(input.name, option(:user), option(:password))
          shell.exec(cmd)[:out].chomp.to_i
        end

        private
        def cmd(db, user, password, dump)
          "mysqldump" +
           " #{credentials(user, password)}" +
           " #{shell_safe(db)} > #{shell.expand_path(dump.path)}"
        end

        def database_size_cmd(db, user, password)
          "echo \"#{database_size_query(db)}\" | " +
            "mysql --skip-column-names #{credentials(user, password)}"
        end

        def database_size_query(db)
          "SELECT sum(data_length+index_length) FROM information_schema.tables" +
            " WHERE table_schema='#{shell_safe(db)}'" +
            " GROUP BY table_schema"
        end

        def credentials(user, password)
          user.nil? && "" ||
            "--user=#{shell_safe(user)} --password=#{shell_safe(password)}"
        end

      end
    end
  end
end
