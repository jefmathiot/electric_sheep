require 'spec_helper'

describe ElectricSheep::Metadata::SshOptions do
  include Support::Options

  it { defines_options :strict_host_key_checking }
end
