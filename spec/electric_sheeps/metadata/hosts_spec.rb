require 'spec_helper'

describe ElectricSheeps::Metadata::Hosts do

    before do
        @hosts = subject.new
    end

    it 'should add host' do
        host = @hosts.add(id: 'some-host', name: 'some-host.tld', description: 'Some host' )
        host.id.must_equal 'some-host'
        host.name.must_equal 'some-host.tld'
        host.description.must_equal 'Some host'
    end

    it 'should use the hostname as the id when id is not explicitly set' do
        host = @hosts.add(name: 'some-host.tld', description: 'Some host' )
        host.id.must_equal host.name
    end

    it 'should find host by id' do
        host = @hosts.add(id: 'some-host', name: 'some-host.tld', description: 'Some host' )
        @hosts.get('some-host').must_equal host
    end

end
