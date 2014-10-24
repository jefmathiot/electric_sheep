require 'spec_helper'
require 'electric_sheep/cli'

describe ElectricSheep::CLI do

  let(:logger){ mock }

  def expects_stdout_logger(level)
    Lumberjack::Logger.expects(:new).with(kind_of(IO), {level: level}).
      returns(logger)
  end

  describe 'work' do

    describe 'when everything goes well' do

      let(:config){ mock }

      before do
        ElectricSheep::Runner::Inline.expects(:new).
          with(all_of(
            has_entry(config: config),
            has_entry(project: 'some-project'),
            has_entry(logger: logger)
          )).returns(mock(run!: true))
      end

      def expects_evaluator(f='Sheepfile')
        ElectricSheep::Sheepfile::Evaluator.expects(:new).with(f).
          returns(mock(evaluate: config))
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
      logger.expects(:debug).with('backtrace')
      subject.new.work
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
      @ex.stubs(:backtrace).returns('backtrace')
      logger.expects(:error).with("fail")
      logger.expects(:debug).with('backtrace')
      subject.new([], key: '/some/key', verbose: true).encrypt('SECRET')
    end

  end

end
