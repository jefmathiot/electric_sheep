module ElectricSheep
  module Commands
    module Database
      class MongoDBDump
        include Command
        include Helpers::Timestamps
        include Helpers::ShellSafe

        register as: "mongodb_dump"

        option :user
        option :password

        def perform
          logger.info "Creating a dump of the \"#{resource.name}\" MongoDB database"
          dump=shell.expand_path(shell_safe("#{resource.name}-#{timestamp}"))
          shell.exec "#{cmd(resource.name, option(:user), option(:password), dump)} &> /dev/null"
          done! shell.directory_resource(shell.host, dump)
        end

        private
        def cmd(db, user, password, output)
          cmd = "mongodump -d #{shell_safe(db)} -o #{output}"
          cmd << " -u #{shell_safe(user)} -p #{shell_safe(password)}" unless user.nil?
          cmd
        end

      end
    end
  end
end
