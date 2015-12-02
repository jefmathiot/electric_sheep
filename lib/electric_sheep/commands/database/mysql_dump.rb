module ElectricSheep
  module Commands
    module Database
      class MySQLDump
        include Command

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
          'SELECT sum(data_length+index_length)' \
            ' FROM information_schema.tables' \
            " WHERE table_schema='#{shell.safe(db)}'" \
            ' GROUP BY table_schema'
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
      end
    end
  end
end
