require 'spec_helper'
require 'electric_sheep/cli'

describe ElectricSheeps::CLI do

  describe 'work' do

    describe 'when everything goes well' do

      before do
        @config, @logger = mock, mock
        ElectricSheeps::Log::ConsoleLogger.expects(:new).with(kind_of(IO), kind_of(IO)).
        returns(@logger)
        ElectricSheeps::Runner.expects(:new).
        with(all_of(
          has_entry(config: @config),
          has_entry(logger: @logger)
          )).returns(mock(run!: true))
      end

      it 'gets the job done' do
        ElectricSheeps::Sheepfile::Evaluator.expects(:new).with('Sheepfile').
        returns(mock(evaluate: @config))
        subject.new.work
      end

      it 'overrides default config option' do
        ElectricSheeps::Sheepfile::Evaluator.expects(:new).with('Lambfile').
        returns(mock(evaluate: @config))
        subject.new([], config: 'Lambfile').work
      end

    end

    it 'raises a Thor error if something went wrong' do
      ElectricSheeps::Sheepfile::Evaluator.expects(:new).with('Sheepfile').
      raises(RuntimeError.new)
      -> { subject.new.work }.must_raise Thor::Error
    end

  end

end
