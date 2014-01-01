require 'spec_helper'

describe ElectricSheeps::Config do
    include Support::Queue

    def queue_items
        ([0]*2).map do
            ElectricSheeps::Metadata::Project.new
        end
    end

    before do
        @config = subject.new
    end

    it 'initializes an empty hosts' do
        @config.hosts.must_be_instance_of ElectricSheeps::Metadata::Hosts
    end

end
