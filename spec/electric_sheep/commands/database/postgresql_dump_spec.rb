require 'spec_helper'
require 'timecop'

describe ElectricSheep::Commands::Database::PostgreSQLDump do
  include Support::Command

  it do
    defines_options :user, :password, :sudo_as, :login_host, :exclude_tables
  end

  it 'should have registered as the "postgresql_dump" agent of type command' do
    ElectricSheep::Agents::Register
      .command('postgresql_dump')
      .must_equal subject
  end

  def expects_log
    logger.expects(:info).in_sequence(seq).with(
      'Creating a dump of the "$MyDatabase" PostgreSQL database'
    )
  end

  def expects_db_stat(options = [], prolog = [])
    query = "SELECT pg_database_size('$MyDatabase')"
    cmd = prolog.dup
                .<<(' psql')
                .<<(' --no-password')
                .concat(options)
                .<<(' -t -d \\$MyDatabase')
                .<<(" -c \"#{query}\"")
    shell.expects(:exec).in_sequence(seq).with(*cmd).returns(out: '4096')
  end

  def expects_exec(options = [], prolog = [])
    cmd = prolog.<<(' pg_dump')
                .<<(' --no-password')
                .concat(options)
                .<<(' -d \\$MyDatabase >')
                .<<(" #{safe_output_path}")
    ensure_execution cmd
  end

  def expects_stat_and_exec(options = [], prolog = [])
    expects_db_stat options, prolog
    expects_exec options, prolog
  end

  def stub_metadata(options = {})
    [:user, :password, :sudo_as, :login_host, :exclude_tables].each do |attr|
      metadata.stubs(attr).returns(options[attr])
    end
  end

  executing do
    let(:output_name) { '$MyDatabase-20140605-040302' }
    let(:output_ext) { '.sql' }
    let(:output_type) { :file }
    let(:database) do
      ElectricSheep::Resources::Database.new name: '$MyDatabase'
    end
    let(:input) { database }

    describe 'not excluding tables' do
      before do
        metadata.stubs(:exclude_tables).returns(nil)
      end

      it 'executes the backup command' do
        escapes '$MyDatabase', output_path
        stub_metadata
        expects_stat_and_exec
      end

      it 'prepends the password' do
        escapes 'secret', '$MyDatabase', output_path
        stub_metadata password: 'secret'
        expects_stat_and_exec [], ['PGPASSWORD=',
                                   kind_of(ElectricSheep::Command::LoggerSafe)]
      end

      it 'impersonates' do
        escapes 'postgres', '$MyDatabase', output_path
        stub_metadata sudo_as: 'postgres'
        expects_stat_and_exec [], ['sudo -n -u postgres ']
      end

      it 'combines sudo and password' do
        escapes 'postgres', 'secret', '$MyDatabase', output_path
        stub_metadata sudo_as: 'postgres', password: 'secret'
        expects_stat_and_exec [], ['sudo -n -u postgres ', 'PGPASSWORD=',
                                   kind_of(ElectricSheep::Command::LoggerSafe)]
      end

      it 'appends the username to the options' do
        escapes '$operator', '$MyDatabase', output_path
        stub_metadata user: '$operator'
        expects_stat_and_exec [' -U \$operator']
      end

      it 'appends the login host to the options' do
        escapes 'localhost', '$MyDatabase', output_path
        stub_metadata login_host: 'localhost'
        expects_stat_and_exec [' -h localhost']
      end
    end

    describe 'excluding tables' do
      before do
        expects_db_stat
      end

      it 'excludes a single table' do
        escapes '$MyDatabase', '$my_table', output_path
        stub_metadata exclude_tables: '$my_table'
        expects_exec [' --exclude-table-data=\\$my_table',
                      ' --exclude-table=\\$my_table']
      end

      it 'excludes multiple tables' do
        escapes '$MyDatabase', '$table1', '$table2', output_path
        stub_metadata exclude_tables: ['$table1', '$table2']
        expects_exec [' --exclude-table-data=\\$table1',
                      ' --exclude-table=\\$table1',
                      ' --exclude-table-data=\\$table2',
                      ' --exclude-table=\\$table2']
      end
    end
  end
end
