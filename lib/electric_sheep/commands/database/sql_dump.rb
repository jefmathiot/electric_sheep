module ElectricSheep
  module Commands
    module Database
      module SQLDump
        extend ActiveSupport::Concern
        include Command

        included do
          option :user
          option :password, secret: true
          option :exclude_tables
        end
      end
    end
  end
end
