require 'spec_helper'
require 'timecop'

describe ElectricSheeps::Commands::Database::MySQLDump do

  it 'should have registered as the "mysql_dump" agent of type command' do
    ElectricSheeps::Commands::Register.command("mysql_dump").must_equal subject
  end

  describe "executing the command" do

    before do
      @project, @logger, @shell = ElectricSheeps::Metadata::Project.new, mock, mock
      @database = ElectricSheeps::Resources::Database.new name: 'MyDatabase'
      @project.start_with! @database

      @command = subject.new(@project, @logger, @shell, '/tmp', nil)
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
      Timecop.travel Time.utc(2014, 6, 5, 4, 3, 2) do
        @shell.expects(:exec).in_sequence(@seq).
          with "mysqldump \"MyDatabase\" > \"/tmp/MyDatabase-20140605-040302.sql\""
        @command.perform
        assert_product
      end
    end

    it 'appends credentials to the command' do
      Timecop.travel Time.utc(2014, 6, 5, 4, 3, 2) do
        @database.user = 'operator'
        @database.password = 'XYZ'
        @shell.expects(:exec).in_sequence(@seq).
          with regexp_matches(/--user="#{@database.user}" --password="#{@database.password}"/)
        @command.perform
        assert_product
      end
    end

  end

end
