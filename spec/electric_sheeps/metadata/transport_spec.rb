require 'spec_helper'

describe ElectricSheeps::Metadata::Transport do
    include Support::Hosts

    Resource = Class.new do
        include ElectricSheeps::Resources::Resource
    end

    before do
        transport_end = ElectricSheeps::Metadata::TransportEnd
        @source = transport_end.new(host: new_host, resource: Resource.new)
        @destination = transport_end.new(host: new_host, resource: Resource.new)
        @transport = subject.new(from: @source, to: @destination)
    end

    it 'should define a source end' do
        @transport.from.must_equal @source
    end

    it 'should defined a destination end' do
        @transport.to.must_equal @destination
    end

end

describe ElectricSheeps::Metadata::TransportEnd do
    include Support::Hosts
    
    before do
        @end = subject.new( host: @host = new_host, resource: @resource = Resource.new )
    end

    it 'should be bound to an host' do
        @end.host.must_equal @host
    end

    it 'should point to a resource' do
        @end.resource.must_equal @resource
    end
end
