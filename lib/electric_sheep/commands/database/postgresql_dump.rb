module ElectricSheep
  module Commands
    module Database
      class PostgreSQLDump
        include SQLDump

        register as: 'postgresql_dump'

        option :sudo_as
        option :login_host

        def perform!
          logger.info "Creating a dump of the \"#{input.basename}\" " \
                      'PostgreSQL database'
          file_resource(host, extension: '.sql').tap do |dump|
            shell.exec(*cmd(dump))
          end
        end

        def stat_database(input)
          shell.exec(*database_size_cmd(input))[:out].chomp.to_i
        end

        private

        def cmd(dump)
          cmd_options
            .<<(" -d #{shell.safe(input.name)} >")
            .<<(" #{shell.safe(shell.expand_path(dump.path))}")
        end

        def cmd_options
          login_options('pg_dump')
            .concat(login_host_option)
            .concat(ignore_tables)
        end

        def database_size_cmd(input)
          login_options('psql')
            .concat(login_host_option)
            .<<(" -t -d #{shell.safe(input.name)}")
            .<<(" -c \"#{database_size_query(input.name)}\"")
        end

        def database_size_query(db)
          "SELECT pg_database_size('#{db}')"
        end

        def login_host_option
          return [] if option(:login_host).nil?
          [" -h #{shell.safe(option(:login_host))}"]
        end

        def login_options(base)
          [" #{base}"].tap do |cmd|
            password_option(cmd)
            sudo_option(cmd)
            cmd << ' --no-password' # Never prompt
            cmd << " -U #{shell.safe(option(:user))}" if option(:user)
          end
        end

        def password_option(cmd)
          return unless option(:password)
          cmd.unshift logger_safe(shell.safe(option(:password)))
          cmd.unshift 'PGPASSWORD='
        end

        def sudo_option(cmd)
          return unless option(:sudo_as)
          cmd.unshift "sudo -n -u #{shell.safe(option(:sudo_as))} "
        end

        def ignore_tables
          excluded_tables.map do |t|
            t = shell.safe(t)
            [" --exclude-table-data=#{t}", " --exclude-table=#{t}"]
          end.flatten
        end
      end
    end
  end
end
