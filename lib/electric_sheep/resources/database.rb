module ElectricSheep
  module Resources
    class Database < Resource
      include Hosted

      option :name, required: true

      def basename
        name
      end
    end
  end
end
