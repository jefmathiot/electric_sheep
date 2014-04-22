require 'spec_helper'
require 'timecop'

describe ElectricSheep::Commands::Database::MySQLDump do
  include Support::Command

  it{
    defines_options :user, :password
  }

  it 'should have registered as the "mysql_dump" agent of type command' do
    ElectricSheep::Agents::Register.command("mysql_dump").must_equal subject
  end

  describe "executing the command" do

    before do
      @project, @logger, @shell = ElectricSheep::Metadata::Project.new, mock, mock
      database = ElectricSheep::Resources::Database.new name: 'MyDatabase'
      @project.start_with! database

      @command = subject.new(@project, @logger, @shell, '/tmp', @metadata = mock)
      @shell.expects(:remote?).returns(true)
      
      @seq = sequence('command')
      @logger.expects(:info).in_sequence(@seq).with "Creating a dump of the \"MyDatabase\" MySQL database"
    end

    def assert_product
      product = @project.last_product
      product.wont_be_nil
      product.path.must_equal '/tmp/MyDatabase-20140605-040302.sql'
      product.remote?.must_equal true
    end

    it 'executes the backup command' do
      @metadata.stubs(:user).returns(nil)
      @metadata.stubs(:password).returns(nil)
      Timecop.travel Time.utc(2014, 6, 5, 4, 3, 2) do
        @shell.expects(:exec).in_sequence(@seq).
          with "mysqldump \"MyDatabase\" > \"/tmp/MyDatabase-20140605-040302.sql\""
        @command.perform
        assert_product
      end
    end

    it 'appends credentials to the command' do
      @metadata.stubs(:user).returns('operator')
      @metadata.stubs(:password).returns('secret')
      Timecop.travel Time.utc(2014, 6, 5, 4, 3, 2) do
        @shell.expects(:exec).in_sequence(@seq).
          with regexp_matches(/--user="operator" --password="secret"/)
        @command.perform
        assert_product
      end
    end

  end

end
