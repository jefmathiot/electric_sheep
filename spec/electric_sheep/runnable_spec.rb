require 'spec_helper'

describe ElectricSheep::Runnable do
  RunnableKlazz = Class.new do
    include ElectricSheep::Runnable

    attr_reader :logger

    def initialize(job, logger, resource)
      @job = job
      @logger = logger
      @input = resource
    end
  end

  describe RunnableKlazz do
    [:job, :logger, :resource].each do |m|
      let(m) { mock }
    end
    let(:runnable) { subject.new(job, logger, resource) }
    let(:resource) { ElectricSheep::Resources::Resource.new }
    let(:host) { ElectricSheep::Metadata::Host.new }

    it 'uses the provided resource as its input' do
      runnable.send(:input).must_equal resource
    end

    describe 'creating filesystem resources' do
      before do
        job.stubs(:last_product).returns(resource)
        resource.stubs(:basename).returns('resource')
      end

      describe 'creating a file' do
        it 'creates a file resource with an extension' do
          resource.stubs(:extension).returns('.ext')
          output = runnable.send(:file_resource, host)
          output.must_be_instance_of ElectricSheep::Resources::File
          output.path.must_match(/^resource-\d{8}-\d{6}\.ext$/)
        end

        it 'creates a file resource without an extension' do
          output = runnable.send(:file_resource, host)
          output.must_be_instance_of ElectricSheep::Resources::File
          output.path.must_match(/^resource-\d{8}-\d{6}$/)
          output.host.must_equal host
        end
      end

      it 'creates a directory' do
        output = runnable.send(:directory_resource, host)
        output.must_be_instance_of ElectricSheep::Resources::Directory
        output.path.must_match(/^resource-\d{8}-\d{6}$/)
        output.host.must_equal host
      end
    end
  end
end
