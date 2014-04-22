require 'spec_helper'

describe ElectricSheep::Resources::Database do
  include Support::Properties

  it{
    defines_properties :name
    requires :name
  }
end
