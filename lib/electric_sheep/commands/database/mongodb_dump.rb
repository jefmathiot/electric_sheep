module ElectricSheep
  module Commands
    module Database
      class MongoDBDump
        include Command
        include Helpers::Named

        register as: "mongodb_dump"

        option :user
        option :password

        def perform
          logger.info "Creating a dump of the \"#{resource.name}\" MongoDB database"
          dump = with_named_dir(
            shell.project_directory,
            resource.name,
            timestamp: true
          ) do |output|
            shell.exec "#{cmd(resource.name, option(:user), option(:password), output)} &> /dev/null"
          end
          done! shell.directory_resource(shell.host, dump)
        end

        private
        def cmd(db, user, password, output)
          cmd = "mongodump -d \"#{shell_safe(db)}\" -o \"#{output}\""
          cmd << " -u \"#{shell_safe(user)}\" -p \"#{shell_safe(password)}\"" unless user.nil?
          cmd
        end

      end
    end
  end
end
