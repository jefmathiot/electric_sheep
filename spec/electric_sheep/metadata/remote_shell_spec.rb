require 'spec_helper'

describe ElectricSheep::Metadata::RemoteShell do
  include Support::ShellMetadata
  include Support::Options
  include Support::Hosts

  it{
    defines_options :user
    requires :user
  }

end
