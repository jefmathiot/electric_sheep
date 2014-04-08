require 'spec_helper'

describe ElectricSheep::Metadata::Hosts do

  before do
    @hosts = subject.new
  end

  it 'should add host' do
    host = @hosts.add('some-host', hostname: 'some-host.tld', description: 'Some host' )
    host.id.must_equal 'some-host'
    host.hostname.must_equal 'some-host.tld'
    host.description.must_equal 'Some host'
  end

  it 'should find host by id' do
    host = @hosts.add('some-host', hostname: 'some-host.tld', description: 'Some host' )
    @hosts.get('some-host').must_equal host
  end

  it 'raises an error when host id is unknown' do
    ->{ @hosts.get('another-host')  }.must_raise RuntimeError,
        "Unknown host with id another-host"
  end

end
