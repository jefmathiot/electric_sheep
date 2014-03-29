module ElectricSheeps
  module Commands
    module Database
      class MongoDBDump
        include ElectricSheeps::Commands::Command
        include ElectricSheeps::Helpers::Named

        register as: "mongodb_dump", of_type: :command
        resource :database, kind_of: Resources::Database

        def perform
          logger.info "Creating a dump of the \"#{database.name}\" MongoDB database"
          dump = with_named_dir work_dir, database.name, timestamp: true do |output|
            shell.exec cmd(database.name, database.user, database.password, output)
          end
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
