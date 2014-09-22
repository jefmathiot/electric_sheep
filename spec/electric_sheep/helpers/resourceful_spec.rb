require 'spec_helper'

describe ElectricSheep::Helpers::Resourceful do

  ResourcefulKlazz = Class.new do
    include ElectricSheep::Helpers::Resourceful

    def initialize
      @host=ElectricSheep::Metadata::Host.new
    end

  end

  describe ResourcefulKlazz do

    def assert_resource_created(type, klazz)
      resource=subject.new.send "#{type}_resource", host=mock, '/some/path'
      resource.must_be_instance_of klazz
      resource.path.must_equal '/some/path'
      resource.host.must_equal host
    end

    def self.describe_resource_creation(type, klazz)
      describe "creating a #{type} resource" do
        it 'merges the options' do
          assert_resource_created type, klazz
        end
      end
    end

    describe_resource_creation 'directory', ElectricSheep::Resources::Directory
    describe_resource_creation 'file', ElectricSheep::Resources::File

  end
end
