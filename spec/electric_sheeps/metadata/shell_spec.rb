require 'spec_helper'

describe ElectricSheeps::Metadata::Shell do
    include Support::ShellMetadata

    describe 'with execs added' do
        before do
            @shell = subject.new
            @execs = []
            2.times do
                @execs << @shell.add(ElectricSheeps::Metadata::Exec.new)
            end
        end

        it 'counts execs' do
            @shell.size.must_equal 2
            @shell.remaining.must_equal 2
        end

        it 'retains execs order' do
            @shell.next!.must_equal @execs.first
            @shell.remaining.must_equal 1
            @shell.next!.must_equal @execs.last
            @shell.remaining.must_equal 0
        end

    end
end
