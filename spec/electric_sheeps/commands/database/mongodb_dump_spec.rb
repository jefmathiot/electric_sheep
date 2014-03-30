require 'spec_helper'
require 'timecop'

describe ElectricSheeps::Commands::Database::MongoDBDump do

  before do
    @project, @logger, @shell = ElectricSheeps::Metadata::Project.new, mock, mock
    @database = ElectricSheeps::Resources::Database.new name: 'MyDatabase'

    @command = subject.new('step-id', @project, @logger, @shell, '/tmp', database: @database)
    @shell.expects(:remote?).returns(true)
    
    @seq = sequence('command')
    @logger.expects(:info).in_sequence(@seq).with "Creating a dump of the \"MyDatabase\" MongoDB database"
  end

  def assert_product
    product = @project.product_of('step-id')
    product.path.must_equal '/tmp/MyDatabase-20140605-040302'
    product.remote?.must_equal true
  end

  it 'executes the backup command' do
    Timecop.travel Time.utc(2014, 6, 5, 4, 3, 2) do
      @shell.expects(:exec).in_sequence(@seq).
        with "mongodump -d \"MyDatabase\" -o \"/tmp/MyDatabase-20140605-040302\""
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
