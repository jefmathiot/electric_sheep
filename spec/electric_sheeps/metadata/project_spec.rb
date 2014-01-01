require 'spec_helper'

describe ElectricSheeps::Metadata::Project do
    include Support::Queue

    def queue_items
        [
            ElectricSheeps::Metadata::Shell.new,
            ElectricSheeps::Metadata::Transport.new
        ]
    end

    it "should initialize the project's description" do
        subject.new(description: 'A description').description.must_equal 'A description'
    end

end
