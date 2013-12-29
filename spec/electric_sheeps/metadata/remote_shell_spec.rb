require 'spec_helper'

describe ElectricSheeps::Metadata::RemoteShell do
    include Support::ShellMetadata
    include Support::Hosts

    before do
        @host = new_host
    end

    it 'should be bound to an host' do
        metadata = subject_instance
        metadata.host.must_equal @host
    end

    def subject_instance
        subject.new(host: @host)
    end
end
