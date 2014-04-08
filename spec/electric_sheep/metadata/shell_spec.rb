require 'spec_helper'

describe ElectricSheep::Metadata::Shell do
  include Support::ShellMetadata
  include Support::Queue

  def queue_items
    ([0]*2).map do
      ElectricSheep::Metadata::Command.new
    end
  end

end
