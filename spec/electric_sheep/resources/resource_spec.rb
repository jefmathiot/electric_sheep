require 'spec_helper'

describe ElectricSheep::Resources::Resource do
  include Support::Options

  it {
    defines_options :host
    requires :host
  }
end
