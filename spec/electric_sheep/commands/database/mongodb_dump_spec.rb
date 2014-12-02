require 'spec_helper'
require 'json'

describe ElectricSheep::Commands::Database::MongoDBDump do
  include Support::Command

  it{
    defines_options :user, :password
  }

  ensure_registration "mongodb_dump"

  def expects_log
    logger.expects(:info).in_sequence(seq).with(
      "Creating a dump of the \"$MyDatabase\" MongoDB database"
    )
  end

  def expects_db_stat(creds='')
    shell.expects(:exec).in_sequence(seq).with(
      "mongo \\$MyDatabase #{creds}--quiet --eval 'printjson(db.stats())'"
    ).returns(out: {'storageSize' => 4096}.to_json)
  end

  executing do
    let(:output_name){ "$MyDatabase-20140605-040302" }
    let(:output_type){:directory}
    let(:database){
      ElectricSheep::Resources::Database.new name: '$MyDatabase'
    }
    let(:input){ database }

    it 'executes the backup command' do
      metadata.stubs(:user).returns(nil)
      metadata.stubs(:password).returns(nil)
      expects_db_stat
      ensure_execution(
        "mongodump -d \\$MyDatabase -o #{output_path} &> /dev/null"
      )
    end

    it 'appends credentials to the command' do
      metadata.stubs(:user).returns('$operator')
      metadata.stubs(:password).returns('$secret')
      creds="-u \\$operator -p \\$secret "
      expects_db_stat(creds)
      ensure_execution(
        "mongodump -d \\$MyDatabase -o #{output_path} #{creds}&> /dev/null"
      )
    end

  end

end
