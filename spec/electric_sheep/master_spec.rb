require 'spec_helper'

describe ElectricSheep::Master do
  describe 'spawning processes' do
    let(:logger) { mock }
    let(:banner) { 'Annoucement' }
    let(:seq) { sequence('spawn') }

    describe ElectricSheep::Master::ProcessSpawner do
      let(:pidfile) do
        Tempfile.new('pidfile').tap do |f|
          f.write '9999'
          f.close
        end
      end

      after do
        pidfile.unlink
      end

      it 'reads a pid file' do
        subject.new(nil, pidfile.path).read_pidfile.must_equal 9999
      end

      it 'returns nil if pidfile is not specified' do
        subject.new(nil, nil).read_pidfile.must_be_nil
      end

      it 'returns nil if the pidfile does not exist' do
        subject.new(nil, '/path/to/pid').read_pidfile.must_be_nil
      end

      it 'deletes the pidfile' do
        subject.new(nil, pidfile.path).delete_pidfile
        File.exist?(pidfile.path).must_equal false
      end

      it 'does not attempt to delete a missing pidfile' do
        subject.new(nil, nil).delete_pidfile
        subject.new(nil, '/path/to/pid').delete_pidfile
      end

      class TestSpawner < ElectricSheep::Master::ProcessSpawner
        def test(banner = nil)
          done(banner, 9999)
        end
      end

      describe TestSpawner do
        let(:pidfile2) do
          Tempfile.new('pidfile').tap(&:close)
        end

        after do
          pidfile2.unlink
        end

        it 'writes the pidfile' do
          subject.new(logger, pidfile2).test
          File.read(pidfile2).must_equal "9999\n"
        end

        it 'logs the banner' do
          logger.expects(:info).with("#{banner}, pid: 9999")
          subject.new(logger).test(banner)
        end

        it 'does nothing' do
          subject.new(logger).test
          File.read(pidfile2).must_equal ''
        end
      end
    end

    describe ElectricSheep::Master::DaemonSpawner do
      let(:spawner) { subject.new(logger) }

      it 'forks and place the process in the background' do
        IO.expects(:pipe).in_sequence(seq)
          .returns([reader = mock, writer = mock])
        spawner.expects(:fork).in_sequence(seq).yields.returns(10_000)
        Process.expects(:daemon).in_sequence(seq)
        reader.expects(:close).in_sequence(seq)
        Process.expects(:pid).in_sequence(seq).returns(10_001)
        writer.expects(:puts).in_sequence(seq).with(10_001)
        (block = mock).expects(:called!).in_sequence(seq)
        Process.expects(:detach).in_sequence(seq).with(10_000)
        reader.expects(:gets).in_sequence(seq).returns('10001')
        spawner.expects(:done).in_sequence(seq).with(banner, 10_001)
        spawner.spawn(banner) do
          block.called!
        end
      end
    end

    describe ElectricSheep::Master::ForkSpawner do
      let(:spawner) { subject.new(logger) }

      it 'forks' do
        spawner.expects(:fork).in_sequence(seq).yields.returns(10_000)
        (block = mock).expects(:called!).in_sequence(seq)
        Process.expects(:detach).in_sequence(seq).with(10_000)
        spawner.expects(:done).in_sequence(seq).with(banner, 10_000)
        spawner.spawn(banner) do
          block.called!
        end
      end
    end

    describe ElectricSheep::Master::InlineSpawner do
      let(:spawner) { subject.new(logger) }

      it 'keeps execution in the same process' do
        Process.expects(:pid).returns(10_000)
        spawner.expects(:done).in_sequence(seq).with(banner, 10_000)
        (block = mock).expects(:called!).in_sequence(seq)
        spawner.spawn(banner) do
          block.called!
        end
      end
    end
  end

  it 'defaults the number of workers to 1' do
    subject.new({}).instance_variable_get(:@workers).must_equal 1
  end

  it 'uses the provided number of workers' do
    subject.new(workers: 2).instance_variable_get(:@workers).must_equal 2
  end

  it 'ignores a non-positive number of workers' do
    subject.new(workers: 0).instance_variable_get(:@workers).must_equal 1
  end

  it 'spawns master inline and forks children' do
    subject.new(daemon: false, pidfile: 'pid').tap do |master|
      master.spawners.master
        .must_be_instance_of ElectricSheep::Master::InlineSpawner
      master.spawners.master.instance_variable_get(:@pidfile).must_be_nil
      master.spawners.worker
        .must_be_instance_of ElectricSheep::Master::ForkSpawner
    end
  end

  it 'spawns all processes as daemons' do
    subject.new(daemon: true, pidfile: 'pid').tap do |master|
      master.spawners.master
        .must_be_instance_of ElectricSheep::Master::DaemonSpawner
      master.spawners.master.instance_variable_get(:@pidfile)
        .must_equal File.expand_path('pid')
      master.spawners.worker
        .must_be_instance_of ElectricSheep::Master::DaemonSpawner
    end
  end

  let(:config) { mock }
  let(:logger) { mock }
  let(:master) do
    subject.new(
      config: config,
      logger: logger,
      pidfile: 'path/to/pidfile'
    )
  end
  let(:seq) { sequence(:fork) }

  describe 'starting' do
    before do
      master.stubs(:should_stop?).returns(false).then.returns(true)
    end

    it 'raises if a process is already running' do
      master.spawners.master.expects(:read_pidfile).returns(9999)
      Process.expects(:kill).with(0, 9999).returns(true)
      err = -> { master.start! }.must_raise RuntimeError
      err.message.must_equal 'Another master seems to be running'
    end

    describe 'without a process running' do
      before do
        logger.expects(:info).with('Starting master')
      end

      def expects_startup(&_block)
        master.spawners.master.expects(:spawn).in_sequence(seq)
          .with('Master started').yields
        master.expects(:trap_signals).in_sequence(seq)
        logger.expects(:debug).in_sequence(seq)
          .with('Searching for scheduled jobs')
        yield if block_given?
        master.expects(:sleep).in_sequence(seq).with(1)
      end

      def expects_child_worker(&_block)
        config.stubs(:iterate).yields(job = mock)
        job.stubs(:id).returns('some-job')
        expects_startup do
          job.expects(:on_schedule).in_sequence(seq).yields
          logger.expects(:info).in_sequence(seq)
            .with("Forking a new worker to handle job \"some-job\"")
          master.spawners.worker.expects(:spawn).yields.returns(10_001)
          ElectricSheep::Runner::SingleRun.expects(:new).in_sequence(seq)
            .with(config, logger, job).returns(runner = mock)
          runner.expects(:run!)
          logger.expects(:debug).in_sequence(seq)
            .with("Forked a worker for job \"some-job\", pid: 10001")
          yield if block_given?
        end
      end

      it 'spawns a master process' do
        config.stubs(:iterate)
        expects_startup do
          logger.expects(:debug).in_sequence(seq).with('Active workers: 0')
        end
        master.start!
      end

      it 'spawns then launches a worker' do
        expects_child_worker do
          Process.expects(:kill).with(0, 10_001).in_sequence(seq).returns(true)
          logger.expects(:debug).in_sequence(seq).with('Active workers: 1')
        end
        master.start!
      end

      it 'forks then flushes a completed worker' do
        expects_child_worker do
          Process.expects(:kill).with(0, 10_001).in_sequence(seq).returns(false)
          logger.expects(:info).in_sequence(seq)
            .with("Worker for job \"some-job\" completed, pid: 10001")
          logger.expects(:debug).in_sequence(seq).with('Active workers: 0')
        end
        master.start!
      end

      it 'does not fork when the max number of workers has been reached' do
        config.stubs(:iterate).yields(job = mock)
        master.instance_variable_set(:@workers, 0)
        expects_startup do
          job.expects(:on_schedule).never
          logger.expects(:debug).in_sequence(seq).with('Active workers: 0')
        end
        master.start!
      end
    end
  end

  it 'restarts' do
    # Definitely enjoyed writing this test
    master.expects(:stop!).in_sequence(seq)
    master.expects(:start!).in_sequence(seq)
    master.restart!
  end

  it 'stops' do
    master.spawners.master.expects(:read_pidfile).returns(9999)
    logger.expects(:info).in_sequence(seq).with('Stopping master')
    Process.expects(:kill).in_sequence(seq).with(0, 9999).returns(true)
    logger.expects(:debug).in_sequence(seq)
      .with('Terminating process 9999')
    Process.expects(:kill).in_sequence(seq).with(15, 9999).returns(true)
    master.spawners.master.expects(:delete_pidfile).in_sequence(seq)
    master.stop!
  end

  it 'removes stale pidfiles' do
    master.spawners.master.expects(:read_pidfile).returns(9999)
    logger.expects(:warn).with('Removing pid file ' \
      "#{File.expand_path('path/to/pidfile')} as the " \
      'process with pid 9999 does not exist anymore')
    master.spawners.master.expects(:delete_pidfile)
    master.running?
  end

  it 'traps the TERM signal' do
    master.expects(:trap).with(:TERM).yields
    master.send(:should_stop?).must_be_nil
    master.send(:trap_signals)
    master.send(:should_stop?).must_equal true
  end
end
