require 'spec_helper'
require 'timecop'

describe ElectricSheeps::Commands::Database::MongoDBDump do

  it 'should have registered as "mongodb_dump"' do
    ElectricSheeps::Commands::Register.command("mongodb_dump").must_equal subject
  end

  describe "executing the command" do

    before do
      @project, @logger, @shell = ElectricSheeps::Metadata::Project.new, mock, mock
      @database = ElectricSheeps::Resources::Database.new name: 'MyDatabase'
      @project.start_with! @database

      @command = subject.new(@project, @logger, @shell, '/tmp', nil)
      @shell.expects(:remote?).returns(true)
      
      @seq = sequence('command')
      @logger.expects(:info).in_sequence(@seq).with "Creating a dump of the \"MyDatabase\" MongoDB database"
    end

    def assert_product
      product = @project.last_product
      product.wont_be_nil
      product.path.must_equal '/tmp/MyDatabase-20140605-040302'
      product.remote?.must_equal true
    end

    it 'executes the backup command' do
      Timecop.travel Time.utc(2014, 6, 5, 4, 3, 2) do
        @shell.expects(:exec).in_sequence(@seq).
          with "mongodump -d \"MyDatabase\" -o \"/tmp/MyDatabase-20140605-040302\" &> /dev/null"
        @command.perform
        assert_product
      end
    end

    it 'appends credentials to the command' do
      Timecop.travel Time.utc(2014, 6, 5, 4, 3, 2) do
        @database.user = 'operator'
        @database.password = 'XYZ'
        @shell.expects(:exec).in_sequence(@seq).
          with regexp_matches(/-u "#{@database.user}" -p "#{@database.password}"/)
        @command.perform
        assert_product
      end
    end

  end
end
