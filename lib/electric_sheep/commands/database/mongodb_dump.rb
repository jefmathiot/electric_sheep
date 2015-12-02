require 'json'

module ElectricSheep
  module Commands
    module Database
      class MongoDBDump
        include Command

        register as: 'mongodb_dump'

        option :user
        option :password, secret: true

        def perform!
          logger.info "Creating a dump of the \"#{input.basename}\" " \
                      'MongoDB database'
          directory_resource(host).tap do |dump|
            shell.exec(*cmd(input.name, option(:user), option(:password), dump))
          end
        end

        def stat_database(input)
          cmd = database_size_cmd(input.name, option(:user), option(:password))
          JSON.parse(shell.exec(*cmd)[:out])['storageSize']
        end

        private

        def cmd(db, user, password, dump)
          [
            "mongodump -d #{shell.safe(db)}",
            " -o #{shell.safe(shell.expand_path(dump.path))}"
          ].concat(credentials(user, password))
           .<< ' &> /dev/null'
        end

        def database_size_cmd(db, user, password)
          ["mongo #{shell.safe(db)}"]
            .concat(credentials(user, password))
            .<< " --quiet --eval 'printjson(db.stats())'"
        end

        def credentials(user, password)
          return [] if user.nil?
          [" -u #{shell.safe(user)}",
           ' -p ', logger_safe(shell.safe(password))]
        end
      end
    end
  end
end
