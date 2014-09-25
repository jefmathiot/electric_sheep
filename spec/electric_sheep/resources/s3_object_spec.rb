require 'spec_helper'

describe ElectricSheep::Resources::S3Object do
  include Support::Options

  it {
    defines_options :key, :bucket
    requires :key, :bucket
  }
end
