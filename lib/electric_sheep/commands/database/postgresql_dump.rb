module ElectricSheep
  module Commands
    module Database
      class PostgreSQLDump
        include Command
        include Helpers::ShellSafe

        register as: 'postgresql_dump'

        option :sudo_as
        option :user
        option :login_host
        option :password, secret: true

        def perform!
          logger.info "Creating a dump of the \"#{input.basename}\" " \
                      'PostgreSQL database'
          file_resource(host, extension: '.sql').tap do |dump|
            shell.exec cmd(dump)
          end
        end

        def stat_database(input)
          shell.exec(database_size_cmd(input))[:out].chomp.to_i
        end

        private

        def cmd(dump)
          login_options('pg_dump') + login_host_option +
            " -d #{shell_safe(input.name)} > #{shell.expand_path(dump.path)}"
        end

        def database_size_cmd(input)
          login_options('psql') + login_host_option +
            " -t -d #{shell_safe(input.name)}" \
            " -c \"#{database_size_query(input.name)}\""
        end

        def database_size_query(db)
          "SELECT pg_database_size('#{shell_safe(db)}')"
        end

        def login_host_option
          option(:login_host).nil? && '' ||
            " -h #{shell_safe(option(:login_host))}"
        end

        def login_options(cmd)
          if option(:password)
            cmd = "PGPASSWORD=#{shell_safe(option(:password))} #{cmd}"
          end
          if option(:sudo_as)
            cmd = "sudo -n -u #{shell_safe(option(:sudo_as))} #{cmd}"
          end
          cmd << ' --no-password' # Never prompt
          cmd << " -U #{shell_safe(option(:user))}" if option(:user)
          cmd
        end
      end
    end
  end
end
