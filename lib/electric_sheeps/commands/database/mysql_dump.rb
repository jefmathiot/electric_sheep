module ElectricSheeps
  module Commands
    module Database
      class MySQLDump
        include ElectricSheeps::Commands::Command

        register as: "mysql_dump", of_type: :command

        resource :database, kind_of: Resources::Database

        def perform
          logger.info "Creating a dump of the \"#{database.name}\" MySQL database"
        end

      end
    end
  end
end
