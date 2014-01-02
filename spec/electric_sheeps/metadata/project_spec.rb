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
        project = subject.new(id: 'some-project', description: 'Some project')
        project.id.must_equal 'some-project'
        project.description.must_equal 'Some project'
    end

end
