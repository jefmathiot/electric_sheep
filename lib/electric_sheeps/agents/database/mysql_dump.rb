module ElectricSheeps
  module Agents
    module Database
      class MySQLDump
        include ElectricSheeps::Agents::Agent

        register as: "mysql_dump", of_type: :command

        resource :database, kind_of: Resources::Database

      end
    end
  end
end
