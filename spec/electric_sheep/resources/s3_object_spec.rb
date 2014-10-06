require 'spec_helper'

describe ElectricSheep::Resources::S3Object do
  include Support::Options
  include Support::Files::Named
  include Support::Files::Extended

  it {
    defines_options :directory, :bucket
    requires :bucket
  }
end
