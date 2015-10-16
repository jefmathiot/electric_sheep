require 'spec_helper'

describe ElectricSheep::Metadata::SshOptions do
  include Support::Options

  it do
    defines_options :host_key_checking, :known_hosts
    defaults_option :host_key_checking, 'standard'
  end
end
