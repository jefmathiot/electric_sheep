require 'spec_helper'

describe ElectricSheep::Metadata::Job do
  include Support::Queue
  include Support::Options

  def queue_items
    [
      ElectricSheep::Metadata::Shell.new,
      ElectricSheep::Metadata::Transport.new
    ]
  end

  it{
    defines_options :id, :description, :private_key
    requires :id
  }

  describe 'validating' do
    let(:step) do
      queue_items.first
    end

    let(:job) do
      subject.new(id: 'some-id').tap do |job|
        job.add step
      end
    end

    it 'adds child steps errors' do
      step.expects(:validate).with(instance_of(ElectricSheep::Config)).
        returns(false)
      expects_validation_error(job, :base, "Invalid step", ElectricSheep::Config.new)
    end

    it 'validates' do
      step.expects(:validate).with(instance_of(ElectricSheep::Config)).
        returns(true)
      job.validate(ElectricSheep::Config.new).must_equal true
    end
  end

  it "initializes" do
    job = subject.new(id: 'some-job')
    job.id.must_equal 'some-job'
  end

  it 'keeps a reference to its initial resource' do
    job = subject.new
    job.start_with!(resource = mock)
    job.starts_with.must_equal resource
  end

  it 'uses its id as the default name' do
    subject.new(id: 'job-name').name.must_equal 'job-name'
  end

  it 'uses its description and id' do
    subject.new(id: 'job-name', description: 'Description').name.
      must_equal 'Description (job-name)'
  end

  describe 'on inspecting schedule' do

    def scheduled(expired, updates, &block)
      schedule=mock(expired?: expired).tap{|s| s.expects(:update!).send(updates)}
      job, called=subject.new.tap{|p| p.schedule!(schedule) }, nil
      job.on_schedule do
        called=true
      end
      yield called if block_given?
      job
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
      job, called=subject.new, nil
      job.on_schedule do
        called=true
      end
      called.must_be_nil "Block should not have been called"
    end

    it 'appends a notifier' do
      subject.new.tap do |job|
        job.notifiers.size.must_equal 0
        job.notifier mock
        job.notifiers.size.must_equal 1
      end
    end

  end

end
