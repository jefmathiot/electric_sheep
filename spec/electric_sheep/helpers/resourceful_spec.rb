require 'spec_helper'

describe ElectricSheep::Helpers::Resourceful do

  ResourcefulKlazz = Class.new do
    include ElectricSheep::Helpers::Resourceful
    
    def initialize
      @host=ElectricSheep::Metadata::Host.new
    end

  end

  describe ResourcefulKlazz do

    def assert_resource_created(type, klazz, local_expected)
      ResourcefulKlazz.any_instance.stubs(:local?).returns local_expected
      resource=subject.new.send "#{type}_resource", path: '/some/path'
      resource.must_be_instance_of klazz
      resource.path.must_equal '/some/path'
      resource.host.send local_expected ? :must_be : :wont_be, :local?
    end

    def self.describe_resource_creation(type, klazz)
      describe "creating a #{type} resource" do
        it 'merges the options and defaults to localhost' do
          assert_resource_created type, klazz, true
        end
        
        it 'merges the options and keep the provided host if remote' do
          assert_resource_created type, klazz, false
        end
      end
    end

    describe_resource_creation 'directory', ElectricSheep::Resources::Directory
    describe_resource_creation 'file', ElectricSheep::Resources::File 

  end
end
