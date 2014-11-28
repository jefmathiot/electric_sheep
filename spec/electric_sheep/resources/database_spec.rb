require 'spec_helper'

describe ElectricSheep::Resources::Database do
  include Support::Options

  it{
    defines_options :name
    requires :name
  }

  it 'lets the world know its type' do
    subject.new.type.must_equal 'database'
  end
end
