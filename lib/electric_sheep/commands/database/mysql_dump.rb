module ElectricSheep
  module Commands
    module Database
      class MySQLDump
        include SQLDump

        register as: 'mysql_dump'

        option :user
        option :password, secret: true

        def perform!
          logger.info "Creating a dump of the \"#{input.basename}\" " \
                      'MySQL database'
          file_resource(host, extension: '.sql').tap do |dump|
            shell.exec(*dump_cmd(dump))
          end
        end

        def stat_database(input)
          shell.exec(*database_size_cmd(input))[:out].chomp.to_i
        end

        private

        def dump_cmd(dump)
          ['mysqldump']
            .concat(credentials)
            .concat(ignore_tables)
            .<< " #{shell.safe(input.name)} > "
            .<< shell.safe(shell.expand_path(dump.path))
        end

        def database_size_cmd(input)
          [
            "echo \"#{database_size_query(input.name)}\" | ",
            'mysql --skip-column-names'
          ].concat(credentials)
        end

        def database_size_query(db)
          query = 'SELECT sum(data_length+index_length)' \
                  ' FROM information_schema.tables' \
                  " WHERE table_schema='#{shell.safe(db)}'"
          if option(:exclude_tables)
            tables = excluded_tables.map { |t| "'#{shell.safe(t)}'" }.join(', ')
            query << " AND table_name NOT IN (#{tables})"
          end
          query << ' GROUP BY table_schema'
        end

        def credentials
          return [] if option(:user).nil?
          [
            ' --user=',
            shell.safe(option(:user)),
            ' --password=',
            logger_safe(shell.safe(option(:password)))
          ]
        end

        def excluded_tables
          tables = option(:exclude_tables)
          (tables.is_a?(Enumerable) && tables || [tables]).compact
        end

        def ignore_tables
          db = shell.safe(input.name)
          excluded_tables.map do |t|
            " --ignore-table=#{db}.#{shell.safe(t)}"
          end
        end
      end
    end
  end
end
