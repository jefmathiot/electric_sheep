require 'spec_helper'
require 'electric_sheep/cli'

describe ElectricSheep::CLI do

  let(:logger){ mock }
  let(:config){ mock }

  def expects_stdout_logger(level)
    Lumberjack::Logger.expects(:new).with(kind_of(IO), {level: level}).
      returns(logger)
  end

  def expects_file_logger(level)
    Lumberjack::Logger.expects(:new).with("electric_sheep.log", {level: level}).
    returns(logger)
  end

  def expects_evaluator(f='Sheepfile')
    ElectricSheep::Sheepfile::Evaluator.expects(:new).with(f).
    returns(mock(evaluate: config))
  end

  describe 'start' do

    it 'launch daemon successfully' do
      daemon = daemon_new
      expects_evaluator
      daemon.expects(:start!).returns(true)
      subject.new([], config: 'Sheepfile', pidfile: 'pidfile').tap do |instance|
        expects_file_logger(:info)
        instance.start
      end
    end

    it 'failed to launch daemon' do
      daemon = daemon_new
      expects_evaluator
      expects_file_logger(:info)
      daemon.expects(:start!).raises(@ex = Exception.new('fail'))
      @ex.stubs(:backtrace).returns('backtrace')
      logger.expects(:error).with("fail")
      logger.expects(:debug).with(kind_of(Exception))
      subject.new([], config: 'Sheepfile', pidfile: 'pidfile').tap do |instance|
        instance.expects(:exit_with).with(:daemon_start_fail)
        instance.start
      end
    end

    def daemon_new
      ElectricSheep::Daemon.expects(:new).
      with(all_of(
      has_entry(config: config),
      has_entry(pidfile: 'pidfile'),
      has_entry(logger: logger)
      )).returns(daemon = mock)
      daemon
    end
  end

  describe 'work' do

    describe 'when everything goes well' do

      before do
        ElectricSheep::Runner::Inline.expects(:new).
          with(all_of(
            has_entry(config: config),
            has_entry(project: 'some-project'),
            has_entry(logger: logger)
          )).returns(mock(run!: true))
      end

      describe 'with the verbose option' do

        it 'intializes the logger with the debug level' do
          expects_stdout_logger(:debug)
          expects_evaluator
          subject.new([], config: 'Sheepfile', project: 'some-project', verbose: true).work
        end

      end

      describe 'without the verbose option' do

        before do
          expects_stdout_logger(:info)
        end

        it 'gets the job done' do
          expects_evaluator
          subject.new([], config: 'Sheepfile', project: 'some-project').work
        end

        it 'overrides the default config option' do
          expects_evaluator('Lambfile')
          subject.new([], config: 'Lambfile', project: 'some-project').work
        end

      end

    end

    it 'logs error if an exception occurs' do
      expects_stdout_logger(:info)
      ElectricSheep::Sheepfile::Evaluator.expects(:new).
        raises(@ex = Exception.new('fail'))
      @ex.stubs(:backtrace).returns('backtrace')
      logger.expects(:error).with("fail")
      logger.expects(:debug).with(kind_of(Exception))
      subject.new.tap do |instance|
        instance.expects(:exit_with).with(:work_fail)
        instance.work
      end
    end

  end

  describe 'encrypting plain text' do

    it 'encrypts secrets' do
      expects_stdout_logger(:info)
      ElectricSheep::Crypto.expects(:encrypt).with('SECRET', '/some/key').returns('CIPHER')
      logger.expects(:info).with("CIPHER")
      subject.new([], key: '/some/key').encrypt('SECRET')
    end

    it 'logs error if Exception occurs' do
      expects_stdout_logger(:debug)
      ElectricSheep::Crypto.expects(:encrypt).with('SECRET', '/some/key').
        raises(@ex = Exception.new('fail'))
      logger.expects(:error).with("fail")
      logger.expects(:debug).with(kind_of(Exception))
      subject.new([], key: '/some/key', verbose: true).tap do |instance|
        instance.expects(:exit_with).with(:encrypt_fail)
        instance.encrypt('SECRET')
      end
    end

  end

end
