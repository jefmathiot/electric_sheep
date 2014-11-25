module ElectricSheep
  module Commands
    module Database
      class MongoDBDump
        include Command
        include Helpers::ShellSafe

        register as: "mongodb_dump"

        option :user
        option :password

        def run!
          logger.info "Creating a dump of the \"#{input.basename}\" MongoDB database"
          done!(
            directory_resource.tap do |dump|
              shell.exec cmd(input.name, option(:user), option(:password), dump)
            end
          )
        end

        private
        def cmd(db, user, password, dump)
          cmd = "mongodump -d #{shell_safe(db)} -o #{shell.expand_path(dump.path)}"
          cmd << " -u #{shell_safe(user)} -p #{shell_safe(password)}" unless user.nil?
          cmd << " &> /dev/null"
        end

      end
    end
  end
end
