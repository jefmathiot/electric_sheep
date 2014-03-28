module ElectricSheeps
  module Agents
    module Database
      class MongoDBDump
        include ElectricSheeps::Agents::Command

        register as: "mongodb_dump", of_type: :command
        resource :database, kind_of: Resources::Database

        def run(metadata)
          logger.info "Creating a dump of the \"#{database.name}\" MongoDB database"
          shell.exec "mongodump --db #{database.name} -o"
        end

      end
    end
  end
end
