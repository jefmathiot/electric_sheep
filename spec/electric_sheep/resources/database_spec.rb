require 'spec_helper'

describe ElectricSheep::Resources::Database do
  include Support::Options

  it{
    defines_options :name
    requires :name
  }
end
