module ElectricSheeps
    module Agents
        module Database
            class MySQLDump
                include ElectricSheeps::Agents::Agent

                register as: "mysql_dump", of_type: :command
            
            end
        end
    end
end
