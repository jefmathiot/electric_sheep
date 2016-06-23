require 'spec_helper'

describe ElectricSheep::Runner do
  let(:logger) { mock }
  let(:config) do
    ElectricSheep::Config.new
  end

  let(:script) { sequence('script') }

  let(:job) do
    ElectricSheep::Metadata::Job
      .new(config, id: 'first-job',
                   description: 'First job description').tap do |p|
      p.stubs(:execution_time).returns(10.112)
    end
  end

  describe ElectricSheep::Runner::Inline do
    let(:runner) { subject.new(config: config, logger: logger) }

    let(:resource) do
      mock.tap do |resource|
        resource.stubs(:to_location).returns(mock)
      end
    end

    before do
      config.add(job)
      job.start_with! resource
    end

    it 'raises when told to run an unknown job' do
      logger.expects(:info).never.with('Executing unknown')
      runner = subject.new(config: config, job: 'unknown', logger: logger)
      err = -> { runner.run! }.must_raise RuntimeError
      err.message.must_equal 'job "unknown" does not exist'
    end

    describe 'executing jobs' do
      before do
        logger.expects(:info).in_sequence(script)
              .with('Executing "First job description (first-job)"')
      end

      describe 'with multiple jobs' do
        before do
          config.add(
            ElectricSheep::Metadata::Job.new(config, id: 'second-job')
          ).tap do |p|
            p.stubs(:execution_time).returns(5.5)
            p.start_with! resource
          end
        end

        def expects_second_job_run
          logger.expects(:info).in_sequence(script)
                .with('Executing "second-job"')
          logger.expects(:info).in_sequence(script)
                .with('job "second-job" completed in 5.500 seconds')
        end

        it 'should not have remaining jobs' do
          logger.expects(:info)
                .with('job "First job description (first-job)" ' \
                'completed in 10.112 seconds')
          expects_second_job_run
          runner.run!
        end

        it 'reports failing jobs' do
          job.add ElectricSheep::Metadata::Shell.new(config)
          shell = ElectricSheep::Shell::LocalShell.any_instance
          shell.expects(:perform!).in_sequence(script)
               .raises(RuntimeError, 'Error message')
          logger.expects(:error).in_sequence(script).with('Error message')
          logger.expects(:debug).in_sequence(script).with(kind_of(RuntimeError))
          expects_second_job_run
          ex = -> { runner.run! }.must_raise RuntimeError
          ex.message.must_equal 'Some jobs have failed: "First job ' \
            'description (first-job)"'
        end

        it 'executes a single job when told to do so' do
          logger.expects(:info)
                .with('job "First job description (first-job)" ' \
                      'completed in 10.112 seconds')
          logger.expects(:info).never.with('Executing "second-job"')
          runner = subject.new(config: config, job: 'first-job',
                               logger: logger)
          runner.run!
        end
      end
    end
  end

  describe ElectricSheep::Runner::SingleRun do
    def host
      config.hosts.get('some-host')
    end

    let(:resource) do
      mock.tap do |resource|
        resource.stubs(:host).returns(host)
        resource.stubs(:to_location).returns(host.to_location)
      end
    end

    let(:runner) do
      subject.new(config, logger, job)
    end

    before do
      config.hosts.add('some-host', hostname: 'some-host.tld')
      config.add job
      logger.expects(:info).in_sequence(script)
            .with('Executing "First job description (first-job)"')
      job.start_with! resource
    end

    def expects_execution_times(*objects)
      objects.each do |monitor|
        monitor.execution_time.wont_be_nil
        monitor.execution_time.must_be :>, 0
      end
    end

    describe 'with shells' do
      def expects_output(metadata)
        metadata.stubs(:last_output).returns(output = mock)
        job.expects(:done!).in_sequence(script)
           .with(metadata, output, output)
        logger.expects(:info).in_sequence(script)
              .with('job "First job description (first-job)" ' \
                    'completed in 10.112 seconds')
      end

      it 'wraps command executions in a local shell' do
        job.add(metadata = ElectricSheep::Metadata::Shell.new(config))
        shell = ElectricSheep::Shell::LocalShell.any_instance
        shell.expects(:perform!).in_sequence(script)
        expects_output(metadata)
        runner.run!.must_equal true
        expects_execution_times(job)
      end

      it 'wraps command executions in a remote shell' do
        job.add(
          metadata = ElectricSheep::Metadata::RemoteShell.new(config,
                                                              user: 'op')
        )
        shell = ElectricSheep::Shell::RemoteShell.any_instance
        shell.expects(:perform!).in_sequence(script).returns(shell)
        expects_output(metadata)
        runner.run!.must_equal true
        expects_execution_times(job)
      end
    end

    class FakeTransport
      include ElectricSheep::Transport
    end

    it 'executes transport' do
      resource.expects(:local?).returns(false)
      resource.stubs(:type).returns('file')
      resource.stubs(:basename).returns('resource')
      resource.stubs(:timestamp?).returns(false)
      job.add metadata = ElectricSheep::Metadata::Transport.new(config)
      metadata.expects(:agent_klazz).in_sequence(script).at_least(1)
              .returns(FakeTransport)
      FakeTransport.any_instance.expects(:run!).in_sequence(script)
      job.expects(:done!).in_sequence(script)
         .with(metadata, kind_of(ElectricSheep::Resources::File), resource)
      logger.expects(:info).in_sequence(script)
            .with('job "First job description (first-job)" ' \
                  'completed in 10.112 seconds')
      runner.run!.must_equal true
      expects_execution_times(job, metadata)
    end

    describe 'with notifiers' do
      let(:notifiers) { [mock, mock] }

      before do
        notifiers.each do |metadata|
          job.notifier metadata
        end
      end

      def expects_notifications
        notifiers.map do |metadata|
          metadata.expects(:agent_klazz).in_sequence(script)
                  .returns(notifier_klazz = mock)
          notifier_klazz.expects(:new).in_sequence(script)
                        .with(job, config.hosts, logger, metadata)
                        .returns(notifier = mock)
          notifier.expects(:notify!).in_sequence(script)
        end
      end

      it 'triggers notifications' do
        expects_notifications
        logger.expects(:info).in_sequence(script)
              .with('job "First job description (first-job)" ' \
                    'completed in 10.112 seconds')
        runner.run!.must_equal true
      end

      it 'fails and notifies' do
        job.add ElectricSheep::Metadata::Shell.new(config)
        ElectricSheep::Shell::LocalShell.any_instance.expects(:perform!)
                                        .raises('An error')
        logger.expects(:error).in_sequence(script).with('An error')
        logger.expects(:debug).in_sequence(script).with(kind_of(RuntimeError))
        expects_notifications
        runner.run!.must_equal false
      end

      it 'ingores failed notifiers' do
        expects_notifications.last.raises('Another error')
        logger.expects(:error).in_sequence(script).with('Another error')
        logger.expects(:debug).in_sequence(script).with(kind_of(RuntimeError))
        logger.expects(:info).in_sequence(script)
              .with('job "First job description (first-job)" ' \
                    'completed in 10.112 seconds')
        runner.run!.must_equal true
      end
    end
  end

  it 'defines logger' do
    single_run = ElectricSheep::Runner::SingleRun.new(nil, logger, nil)
    assert_equal logger, single_run.logger
  end
end
