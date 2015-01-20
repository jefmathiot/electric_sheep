require 'spec_helper'

describe ElectricSheep::Notifiers::Email do
  include Support::Options

  before do
    Mail::TestMailer.deliveries.clear
  end

  let(:resource) do
    ElectricSheep::Resources::File.new(path: 'path/to/file').tap do |resource|
      resource.stat! 1024
    end
  end

  let(:job){
    ElectricSheep::Metadata::Job.new(id: 'some-job').tap do |p|
      report=mock.tap{|m| m.stubs(:stack).returns([])}
      p.stubs(:report).returns(report)
      p.stubs(:last_product).returns(resource)
    end
  }

  let(:metadata){
    ElectricSheep::Metadata::Notifier.new(
      agent: 'email',
      from: 'from@host.tld',
      to: 'to@host.tld',
      using: :test,
      with: {'an_option' => 'value'}
    )
  }
  let(:logger){ mock }
  let(:hosts){ ElectricSheep::Metadata::Hosts.new }

  let(:notifier) do
    subject.new(
      job,
      hosts,
      logger,
      metadata
    )
  end

  it{
    defines_options :from, :to, :using, :with
    # TODO requires :from, :to, :using
  }

  it 'should have registered as the "email" notifier' do
    ElectricSheep::Agents::Register.notifier("email").must_equal subject
  end

  {
    success: 'Backup successful: some-job',
    failed: 'BACKUP FAILED: some-job'
  }.each do |status, subject|
    it "delivers the notification for a job with status #{status}" do
      job.instance_variable_set(:@status, status)
      notifier.notify!
      Mail::TestMailer.deliveries.length.must_equal 1
      Mail::TestMailer.deliveries.first.tap do |delivery|
        delivery.from.must_equal [metadata.from]
        delivery.to.must_equal [metadata.to]
        delivery.subject.must_equal subject
        # Could we ensure preflight has been done without this kind of hack ?
        delivery.html_part.body.to_s.wont_match /\.headerContent/
      end
    end
  end

  it 'symbolizes delivery options' do
    msg=mock
    msg.expects(:delivery_method).with(:test, {an_option: 'value'})
    msg.expects(:deliver)
    notifier.send(:deliver, msg)
  end


end
