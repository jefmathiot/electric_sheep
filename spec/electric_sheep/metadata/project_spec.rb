require 'spec_helper'

describe ElectricSheep::Metadata::Project do
  include Support::Queue
  include Support::Options

  def queue_items
    [
      ElectricSheep::Metadata::Shell.new,
      ElectricSheep::Metadata::Transport.new
    ]
  end

  it{
    defines_options :id, :description
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

  describe 'on inspecting schedule' do

    def scheduled(expired, updates, &block)
      schedule=mock(expired?: expired).tap{|s| s.expects(:update!).send(updates)}
      project, called=subject.new.tap{|p| p.schedule!(schedule) }, nil
      project.on_schedule do
        called=true
      end
      yield called if block_given?
      project
    end

    it 'expose its schedule' do
      scheduled(true, :once).schedule.wont_be_nil
    end

    it 'yields on expiry' do
      scheduled(true, :once) do |called|
        called.must_equal true, "Block should have been called"
      end
    end

    it 'does not yield if schedule has not expired' do
      scheduled(false, :never) do |called|
        called.must_be_nil "Block should not have been called"
      end
    end

    it 'does not yield if it is not scheduled' do
      project, called=subject.new, nil
      project.on_schedule do
        called=true
      end
      called.must_be_nil "Block should not have been called"
    end
  end

end
