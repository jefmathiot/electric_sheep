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

        def excluded_tables
          tables = option(:exclude_tables)
          (tables.is_a?(Enumerable) && tables || [tables]).compact
        end
      end
    end
  end
end
