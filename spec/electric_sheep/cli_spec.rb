require 'spec_helper'
require 'electric_sheep/cli'

describe ElectricSheep::CLI do

  describe 'work' do

    describe 'when everything goes well' do

      before do
        @config, @logger = mock, mock
        ElectricSheep::Log::ConsoleLogger.expects(:new).with(kind_of(IO), kind_of(IO), true).
          returns(@logger)
        ElectricSheep::Runner::Inline.expects(:new).
          with(all_of(
            has_entry(config: @config),
            has_entry(project: 'some-project'),
            has_entry(logger: @logger)
          )).returns(mock(run!: true))
      end

      it 'gets the job done' do
        ElectricSheep::Sheepfile::Evaluator.expects(:new).with('Sheepfile').
          returns(mock(evaluate: @config))
        subject.new([], config: 'Sheepfile', project: 'some-project', verbose:true).work
      end

      it 'overrides the default config option' do
        ElectricSheep::Sheepfile::Evaluator.expects(:new).with('Lambfile').
          returns(mock(evaluate: @config))
        subject.new([], config: 'Lambfile', project: 'some-project', verbose:true).work
      end

    end

    it 'logs error if Exception occurs' do
      ElectricSheep::Log::ConsoleLogger.expects(:new).with(kind_of(IO), kind_of(IO),nil).
          returns(@logger=mock)
      ElectricSheep::Sheepfile::Evaluator.expects(:new).
        raises(@ex = Exception.new('fail'))
      @ex.stubs(:backtrace).returns('backtrace')
      @logger.expects(:error).with("fail")
      @logger.expects(:debug).with('backtrace')
      subject.new.work
    end

  end
  describe 'encrypt' do

    before do
      @logger = mock
      ElectricSheep::Log::ConsoleLogger.expects(:new).with(kind_of(IO), kind_of(IO), true).
        returns(@logger)
    end

    it 'encrypts secrets' do
      ElectricSheep::Crypto.expects(:encrypt).with('SECRET', '/some/key').returns('CIPHER')
      @logger.expects(:info).with("CIPHER")
      subject.new([], key: '/some/key', verbose: true).encrypt('SECRET')
    end

    it 'logs error if Exception occurs' do
      ElectricSheep::Crypto.expects(:encrypt).with('SECRET', '/some/key').
        raises(@ex = Exception.new('fail'))
      @ex.stubs(:backtrace).returns('backtrace')
      @logger.expects(:error).with("fail")
      @logger.expects(:debug).with('backtrace')
      subject.new([], key: '/some/key', verbose: true).encrypt('SECRET')
    end

  end



end
