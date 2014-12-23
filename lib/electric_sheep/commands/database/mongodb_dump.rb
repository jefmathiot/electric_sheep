require 'json'

module ElectricSheep
  module Commands
    module Database
      class MongoDBDump
        include Command
        include Helpers::ShellSafe

        register as: "mongodb_dump"

        option :user
        option :password

        def perform!
          logger.info "Creating a dump of the \"#{input.basename}\" MongoDB database"
          directory_resource(host).tap do |dump|
            shell.exec cmd(input.name, option(:user), option(:password), dump)
          end
        end

        def stat_database(input)
          cmd=database_size_cmd(input.name, option(:user), option(:password))
          JSON.parse(shell.exec(cmd)[:out])['storageSize']
        end

        private
        def cmd(db, user, password, dump)
          cmd = "mongodump -d #{shell_safe(db)} -o #{shell.expand_path(dump.path)}"
          cmd << credentials(user, password)
          cmd << " &> /dev/null"
        end

        def database_size_cmd(db, user, password)
          cmd = "mongo #{shell_safe(db)}"
          cmd << credentials(user, password)
          cmd << " --quiet --eval 'printjson(db.stats())'"
        end

        def credentials(user, password)
          user.nil? && "" ||
          " -u #{shell_safe(user)} -p #{shell_safe(password)}"
        end

      end
    end
  end
end
