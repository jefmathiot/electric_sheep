require 'spec_helper'

describe ElectricSheeps::Metadata::RemoteShell do
    include Support::ShellMetadata

    before do
        @host = ElectricSheeps::Metadata::Hosts.new.add(
            id: 'some-host',
            name: 'some-host.tld',
        )
    end

    it 'should be bound to an host' do
        metadata = subject.new(@host)
        metadata.host.must_equal @host
    end

    def subject_instance
        subject.new(@host)
    end
end
