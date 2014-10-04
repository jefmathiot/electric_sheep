module ElectricSheep
  module Resources
    class Database < Resource
      option :name, required: true

      def basename
        name
      end
    end
  end
end
