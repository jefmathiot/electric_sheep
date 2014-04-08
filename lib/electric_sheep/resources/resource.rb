module ElectricSheep
  module Resources
    module Resource
      extend ActiveSupport::Concern
      include Metadata::Options

      included do
        options :name
      end
    end
  end
end
