require 'spec_helper'
require 'fog'

describe ElectricSheep::Transports::S3 do
  include Support::Options

  it {
    defines_options :access_key_id, :secret_key
  }

end
