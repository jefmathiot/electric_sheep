require 'spec_helper'
require 'timecop'

describe ElectricSheep::Commands::Database::PostgreSQLDump do
  include Support::Command

  it { defines_options :user, :password, :sudo_as, :login_host }

  it 'should have registered as the "postgresql_dump" agent of type command' do
    ElectricSheep::Agents::Register.command('postgresql_dump')
      .must_equal subject
  end

  def expects_log
    logger.expects(:info).in_sequence(seq).with(
      'Creating a dump of the "$MyDatabase" PostgreSQL database'
    )
  end

  def expects_db_stat(options = '', prolog = '')
    query = "SELECT pg_database_size('\\$MyDatabase')"
    cmd = "#{prolog}psql --no-password #{options}" \
      "-t -d \\$MyDatabase -c \"#{query}\""
    shell.expects(:exec).in_sequence(seq).with(cmd).returns(out: '4096')
  end

  def expects_stat_and_exec(options = '', prolog = '')
    expects_db_stat options, prolog
    ensure_execution "#{prolog}pg_dump --no-password #{options}" \
      "-d \\$MyDatabase > #{output_path}"
  end

  def stub_metadata(options = {})
    [:user, :password, :sudo_as, :login_host].each do |attr|
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

    it 'executes the backup command' do
      stub_metadata
      expects_stat_and_exec
    end

    it 'prepends the password' do
      stub_metadata password: 'secret'
      expects_stat_and_exec '', 'PGPASSWORD=secret '
    end

    it 'uses sudo' do
      stub_metadata sudo_as: 'postgres'
      expects_stat_and_exec '', 'sudo -n -u postgres '
    end

    it 'combines sudo and password' do
      stub_metadata sudo_as: 'postgres', password: 'secret'
      expects_stat_and_exec '', 'sudo -n -u postgres PGPASSWORD=secret '
    end

    it 'appends the username to the options' do
      stub_metadata user: 'operator'
      expects_stat_and_exec '-U operator '
    end

    it 'appends the login host to the options' do
      stub_metadata login_host: 'localhost'
      expects_stat_and_exec '-h localhost '
    end
  end
end
