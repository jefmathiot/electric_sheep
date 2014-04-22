require 'spec_helper'

describe ElectricSheep::Metadata::Transport do
  include Support::Hosts
  include Support::Options

  it{
    defines_options :type, :transport, :to
    requires :type, :transport, :to
  }
end

