require 'spec_helper'

describe ElectricSheeps::Metadata::Shell do
    include Support::ShellMetadata
    include Support::Queue

    def queue_items
        ([0]*2).map do
            ElectricSheeps::Metadata::Command.new
        end
    end

end
