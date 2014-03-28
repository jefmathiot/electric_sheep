require 'spec_helper'

describe ElectricSheeps::Agents::S3::S3cmd do

  it 'should have registered as the "s3cmd" agent of type command' do
    ElectricSheeps::Agents::Register.command('s3cmd').must_equal subject
  end

end
