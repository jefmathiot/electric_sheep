require 'spec_helper'
require 'timecop'

describe ElectricSheep::Commands::Database::MySQLDump do
  include Support::Command

  it { defines_options :user, :password }

  it 'should have registered as the "mysql_dump" agent of type command' do
    ElectricSheep::Agents::Register.command('mysql_dump').must_equal subject
  end

  def expects_log
    logger.expects(:info).in_sequence(seq).with(
      'Creating a dump of the "$MyDatabase" MySQL database'
    )
  end

  def expects_db_stat(creds = [])
    query = 'SELECT sum(data_length+index_length) ' \
      "FROM information_schema.tables WHERE table_schema='\\$MyDatabase' " \
      'GROUP BY table_schema'
    shell.expects(:exec).in_sequence(seq).with(
      "echo \"#{query}\" | ", 'mysql --skip-column-names', *creds
    ).returns(out: '4096')
  end

  executing do
    let(:output_name) { '$MyDatabase-20140605-040302' }
    let(:output_ext) { '.sql' }
    let(:output_type) { :file }
    let(:database) do
      ElectricSheep::Resources::Database.new name: '$MyDatabase'
    end
    let(:input) { database }

    it 'executes the backup command' do
      metadata.stubs(:user).returns(nil)
      metadata.stubs(:password).returns(nil)
      escapes '$MyDatabase', output_path
      expects_db_stat
      ensure_execution ['mysqldump', " \\$MyDatabase > #{safe_output_path}"]
    end

    it 'appends credentials to the command' do
      metadata.stubs(:user).returns('$operator')
      metadata.stubs(:password).returns('$secret')
      escapes '$operator', '$secret', '$MyDatabase', output_path
      creds = [' --user=', '\\$operator', ' --password=',
               kind_of(ElectricSheep::Command::LoggerSafe)]
      expects_db_stat(creds)
      ensure_execution(%w(mysqldump)
                       .concat(creds)
                       .<<(" \\$MyDatabase > #{safe_output_path}"))
    end
  end
end
