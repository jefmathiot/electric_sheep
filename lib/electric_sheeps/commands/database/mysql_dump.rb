module ElectricSheeps
  module Commands
    module Database
      class MySQLDump
        include ElectricSheeps::Commands::Command

        register as: "mysql_dump", of_type: :command

        resource :database, kind_of: Resources::Database

      end
    end
  end
end
