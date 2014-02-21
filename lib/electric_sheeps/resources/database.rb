module ElectricSheeps
    module Resources
        class Database
            include Resource

            attr_accessor :user, :password
        end
    end
end
