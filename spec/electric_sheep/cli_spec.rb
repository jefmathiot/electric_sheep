require 'spec_helper'
require 'electric_sheep/cli'

describe ElectricSheep::CLI do

  describe 'work' do

    describe 'when everything goes well' do

      before do
        @config, @logger = mock, mock
        ElectricSheep::Log::ConsoleLogger.expects(:new).with(kind_of(IO), kind_of(IO)).
          returns(@logger)
        ElectricSheep::Runner.expects(:new).
          with(all_of(
            has_entry(config: @config),
            has_entry(logger: @logger)
          )).returns(mock(run!: true))
      end

      it 'gets the job done' do
        ElectricSheep::Sheepfile::Evaluator.expects(:new).with('Sheepfile').
          returns(mock(evaluate: @config))
        subject.new.work
      end

      it 'overrides default config option' do
        ElectricSheep::Sheepfile::Evaluator.expects(:new).with('Lambfile').
          returns(mock(evaluate: @config))
        subject.new([], config: 'Lambfile').work
      end

    end

    it 'encrypt secrets' do
      ElectricSheep::Crypto.expects(:encrypt).with('SECRET', '/some/key').returns('CIPHER')
      STDOUT.expects(:puts).with('CIPHER')
      subject.new([], key: '/some/key').encrypt('SECRET')
    end

    it 'raises a Thor error if something went wrong' do
      ElectricSheep::Sheepfile::Evaluator.expects(:new).with('Sheepfile').
      raises(RuntimeError.new)
      -> { subject.new.work }.must_raise Thor::Error
    end

  end

end
