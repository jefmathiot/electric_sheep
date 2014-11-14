require 'spec_helper'

describe ElectricSheep::Master do

  let(:config){ mock }
  let(:logger){ mock }
  let(:master){
    subject.new(
      config: config,
      logger: logger,
      pidfile: @pidfile.path
    )
  }

  before do
    @pidfile=Tempfile.new('pidfile.lock')
    @pidfile.write "9999\n"
    @pidfile.close
  end

  after do
    @pidfile.unlink
  end

  describe 'starting' do

    before do
      master.stubs(:should_stop?).returns(false).then.returns(true)
    end

    it 'raises if a process is already running' do
      Process.expects(:kill).with(0, 9999).returns(true)
      err = -> { master.start! }.must_raise RuntimeError
      err.message.must_equal 'Another daemon seems to be running'
    end

    describe 'without a process running' do
      let(:seq){ sequence(:fork) }

      before do
        @pidfile_path=@pidfile.path
        @pidfile.unlink
        logger.expects(:info).with("Daemon starting")
      end

      def expects_pidfile
        File.read(@pidfile_path).must_equal "10001\n"
      end

      def expects_daemonize(&block)
        IO.expects(:pipe).in_sequence(seq).returns([reader=mock, writer=mock])
        master.expects(:fork).in_sequence(seq).yields.returns(10000)
        Process.expects(:daemon).in_sequence(seq)
        reader.expects(:close).in_sequence(seq)
        Process.expects(:pid).in_sequence(seq).returns(10001)
        writer.expects(:puts).in_sequence(seq).with(10001)
        yield
        Process.expects(:detach).in_sequence(seq).with(10000)
        reader.expects(:gets).in_sequence(seq).returns('10001')
        logger.expects(:info).in_sequence(seq).
          with("Daemon started, pid: 10001")
      end

      it 'forks' do
        config.stubs(:all).returns([])
        expects_daemonize do
          logger.expects(:debug).in_sequence(seq).
            with("Searching for scheduled projects")
          master.expects(:sleep).with(1)
          logger.expects(:debug).in_sequence(seq).with("Active workers: 0")
        end
        master.start!
        expects_pidfile
      end
    end

    # it 'forks and loops' do
    #   master.start!
    # end

    # it 'runs scheduled projects' do
    # end

  end
end