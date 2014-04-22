require 'spec_helper'

describe ElectricSheep::Metadata::Project do
  include Support::Queue
  include Support::Properties

  def queue_items
    [
      ElectricSheep::Metadata::Shell.new,
      ElectricSheep::Metadata::Transport.new
    ]
  end

  it{
    defines_properties :id, :description
    requires :id
  }

  describe 'validating' do
    let(:step) do
      queue_items.first
    end

    let(:project) do
      subject.new(id: 'some-id').tap do |project|
        project.add step
      end
    end

    it 'adds child steps errors' do
      step.expects(:validate).with(instance_of(ElectricSheep::Config)).
        returns(false)
      expects_validation_error(project, :base, "Invalid step", ElectricSheep::Config.new)
    end

    it 'validates' do
      step.expects(:validate).with(instance_of(ElectricSheep::Config)).
        returns(true)
      project.validate(ElectricSheep::Config.new).must_equal true
    end
  end
  
  it "initializes the project's id" do
    project = subject.new(id: 'some-project')
    project.id.must_equal 'some-project'
    project.products.size.must_equal 0
  end

  it 'uses the initial resource when there are no products' do
    project = subject.new
    project.start_with!(resource = mock)
    project.last_product.must_equal resource
  end

  it 'retrieves the last product' do
    project = subject.new
    project.store_product!(mock)
    project.store_product!(resource = mock)
    project.last_product.must_equal resource
  end

  it 'uses the default private key' do
    subject.new.private_key.must_equal File.expand_path('~/.ssh/id_rsa')
  end

  it 'overrides the private key' do
    project = subject.new
    '/path/to/private/key'.tap do |key|
      project.use_private_key! key
      project.private_key.must_equal key
    end
  end
end
