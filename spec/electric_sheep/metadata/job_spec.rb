require 'spec_helper'

describe ElectricSheep::Metadata::Job do
  include Support::Queue
  include Support::Options

  let(:config) do
    ElectricSheep::Config.new
  end

  def queue_items
    [
      ElectricSheep::Metadata::Shell.new(config),
      ElectricSheep::Metadata::Transport.new(config)
    ]
  end

  it do
    defines_options :id, :description, :private_key
    requires :id
  end

  describe 'validating' do
    let(:step) do
      queue_items.first
    end

    let(:job) do
      subject.new(config, id: 'some-id').tap do |job|
        job.add step
      end
    end

    it 'adds child steps errors' do
      step.expects(:validate).returns(false)
      expects_validation_error(job, :base, 'Invalid step',
                               ElectricSheep::Config.new)
    end

    it 'validates' do
      step.expects(:validate).returns(true)
      job.validate.must_equal true
    end
  end

  it 'initializes' do
    job = subject.new(config, id: 'some-job')
    job.id.must_equal 'some-job'
  end

  it 'keeps a reference to its initial resource' do
    job = subject.new(config)
    job.start_with!(resource = mock)
    job.starts_with.must_equal resource
  end

  it 'uses its id as the default name' do
    subject.new(config, id: 'job-name').name.must_equal 'job-name'
  end

  it 'uses its description and id' do
    subject.new(config, id: 'job-name', description: 'Description').name
      .must_equal 'Description (job-name)'
  end

  let(:job){ subject.new(config) }

  describe 'on inspecting schedule' do
    def scheduled(updates, *expired, &_block)
      expired.each do |expires|
        mock(expired?: expires).tap do |s|
          s.expects(:update!).send(updates)
          job.schedule!(s)
        end
      end
      called = nil
      job.on_schedule do
        called = true
      end
      yield called if block_given?
      job
    end

    it 'expose its schedules' do
      2.times { job.schedule!(mock) }
      job.schedules.length.must_equal 2
    end

    it 'yields on expiry' do
      scheduled(:once, false, true) do |called|
        called.must_equal true, 'Block should have been called'
      end
    end

    it 'does not yield if schedule has not expired' do
      scheduled(:never, false, false) do |called|
        called.must_be_nil 'Block should not have been called'
      end
    end

    it 'does not yield if it is not scheduled' do
      called = nil
      job.on_schedule do
        called = true
      end
      called.must_be_nil 'Block should not have been called'
    end
  end

  it 'appends a notifier' do
    job.notifiers.size.must_equal 0
    job.notifier mock
    job.notifiers.size.must_equal 1
  end
end
