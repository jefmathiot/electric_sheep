require 'spec_helper'

describe ElectricSheeps::Agents::Database::MySQLDump do

    it 'should have registered as the "mysql_dump" agent of type command' do
        ElectricSheeps::Agents::Register.command("mysql_dump").must_equal subject 
    end

end
