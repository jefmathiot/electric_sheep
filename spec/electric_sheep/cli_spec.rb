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

  def self.ensure_verbosity(logger_type=:stdout, &block)

    describe 'with the verbose option' do

      before do
        send "expects_#{logger_type}_logger", :debug
      end

      it 'enables verbose logging' do
        self.instance_eval &block
      end

    end

  end

  def self.concise(logger_type=:stdout, &block)

    describe 'without the verbose option' do

      before do
        send "expects_#{logger_type}_logger", :info
      end

      self.instance_eval &block

    end

  end

  def self.ensure_exception_handling(&block)
    it 'logs the exception' do
      logger.expects(:error).with("fail")
      logger.expects(:debug).with(kind_of(Exception))
      Exception.any_instance.stubs(:backtrace).returns('backtrace')
      self.instance_eval &block
    end
  end

  describe 'working' do

    describe 'when everything goes well' do

      before do
        ElectricSheep::Runner::Inline.expects(:new).
          with(all_of(
            has_entry(config: config),
            has_entry(project: 'some-project'),
            has_entry(logger: logger)
          )).returns(mock(run!: true))
      end

      ensure_verbosity do
        expects_evaluator
        subject.new([], config: 'Sheepfile', project: 'some-project', verbose: true).work
      end

      concise do

        it 'gets the job done' do
          expects_evaluator
          subject.new([], config: 'Sheepfile', project: 'some-project').work
        end

        it 'overrides the path to configuration file' do
          expects_evaluator('Lambfile')
          subject.new([], config: 'Lambfile', project: 'some-project').work
        end

      end

    end

    concise do
      ensure_exception_handling do
        ElectricSheep::Sheepfile::Evaluator.expects(:new).
          raises(Exception.new('fail'))
        subject.new.work
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
      subject.new([], key: '/some/key', verbose: true).encrypt('SECRET')
    end

  end

  describe 'controlling the master process' do

    def expects_master(options)
      ElectricSheep::Master.expects(:new).with(options).returns(master)
    end

    def expects_control(method, master_options, config_file=nil)
      expects_evaluator(config_file || 'Sheepfile')
      expects_master({
        pidfile: nil, logger: logger, config: config
      }.merge(master_options))
      master.expects(method)
    end

    describe 'when everything goes well' do

      concise(:file) do

        let(:master){ mock }

        it 'starts a master' do
          expects_control(:start!, {})
          subject.new([], config: 'Sheepfile').start
        end

        it 'overrides the path to configuration file' do
          expects_control(:start!, {}, 'Lambfile')
          subject.new([], config: 'Lambfile').start
        end

        it 'overrides the path to pidfile' do
          expects_control(:start!, {pidfile: '/tmp/es.lock'})
          subject.new([], config: 'Sheepfile', pidfile: '/tmp/es.lock').start
        end

      end

    end

  end

end
