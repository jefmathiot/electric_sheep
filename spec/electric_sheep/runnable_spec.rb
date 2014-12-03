require 'spec_helper'

describe ElectricSheep::Runnable do

  RunnableKlazz = Class.new do
    include ElectricSheep::Runnable

    attr_reader :logger

    def initialize(project, logger)
      @project=project
      @logger=logger
    end
  end

  describe RunnableKlazz do

    let(:project){ mock }
    let(:logger){ mock }
    let(:runnable){ subject.new(project, logger) }
    let(:resource){ ElectricSheep::Resources::Resource.new }
    let(:host){ ElectricSheep::Metadata::Host.new }

    it 'marks the run done' do
      project.expects(:store_product!).with(resource)
      runnable.send(:done!, resource)
    end

    it 'uses the previous product as its input' do
      project.expects(:last_product).returns(resource)
      runnable.send(:input).must_equal resource
    end

    describe 'trying to stat a resource' do

      let(:interactor){ mock }

      it 'stats the resource using the interactor' do
        interactor.expects(:stat).with(resource).returns(1024)
        runnable.send(:stat!, resource, interactor)
        resource.stat.size.must_equal 1024

      end
      it 'rescues interactor failure' do
        logger.expects(:warn).
          with("Unable to stat resource of type resource: Exception")
        interactor.expects(:stat).with(resource).raises('Exception')
        runnable.send(:stat!, resource, interactor)
      end

    end

    describe 'creating filesystem resources' do

      before do
        project.stubs(:last_product).returns(resource)
        resource.stubs(:basename).returns('resource')
      end

      describe 'creating a file' do

        it 'creates a file resource with an extension' do
          resource.stubs(:extension).returns('.ext')
          output=runnable.send(:file_resource, host)
          output.must_be_instance_of ElectricSheep::Resources::File
          output.path.must_match /^resource-\d{8}-\d{6}\.ext$/
        end

        it 'creates a file resource without an extension' do
          output=runnable.send(:file_resource, host)
          output.must_be_instance_of ElectricSheep::Resources::File
          output.path.must_match /^resource-\d{8}-\d{6}$/
          output.host.must_equal host
        end

      end

      it 'creates a directory' do
        output=runnable.send(:directory_resource, host)
        output.must_be_instance_of ElectricSheep::Resources::Directory
        output.path.must_match /^resource-\d{8}-\d{6}$/
        output.host.must_equal host
      end

    end

  end

end
