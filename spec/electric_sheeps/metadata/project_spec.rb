require 'spec_helper'

describe ElectricSheeps::Metadata::Project do

    it "should initialize the project's description" do
        subject.new(description: 'A description').description.must_equal 'A description'
    end

    describe 'with steps added' do
        before do
            @project = subject.new(description: 'A description')
            @shell = @project.add(ElectricSheeps::Metadata::Shell.new)
            @transport = @project.add(ElectricSheeps::Metadata::Transport.new())
        end

        it 'counts steps' do
            @project.size.must_equal 2
            @project.remaining.must_equal 2
        end

        it 'retains steps order' do
            @project.next!.must_equal @shell
            @project.remaining.must_equal 1
            @project.next!.must_equal @transport
            @project.remaining.must_equal 0
        end

    end
end
