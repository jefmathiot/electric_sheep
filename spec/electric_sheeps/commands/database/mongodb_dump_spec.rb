require 'spec_helper'
require 'timecop'

describe ElectricSheeps::Commands::Database::MongoDBDump do

  before do
    @logger, @shell = mock, mock
    @database = ElectricSheeps::Resources::Database.new name: 'MyDatabase'
    @command = subject.new(@logger, @shell, '/tmp', database: @database)
    
    @seq = sequence('command')
    @logger.expects(:info).in_sequence(@seq).with "Creating a dump of the \"MyDatabase\" MongoDB database"
  end

  it 'executes the backup command' do
    Timecop.travel Time.utc(2014, 6, 5, 4, 3, 2) do
      @shell.expects(:exec).in_sequence(@seq).with "mongodump -d \"MyDatabase\" -o \"/tmp/MyDatabase-20140605-040302\""
      @command.perform
    end
  end

  it 'appends credentials to the command' do
    @database.user = 'operator'
    @database.password = 'XYZ'
    @shell.expects(:exec).in_sequence(@seq).with regexp_matches(/-u "#{@database.user}" -p "#{@database.password}"/)
    @command.perform
  end

end
