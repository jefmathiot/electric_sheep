module ElectricSheep
  module Resources
    class Database
      include Resource

      options :name, :user, :password
    end
  end
end
