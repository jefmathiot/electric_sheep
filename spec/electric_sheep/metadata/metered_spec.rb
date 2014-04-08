require 'spec_helper'

describe ElectricSheep::Metadata::Metered do
  MeteredKlazz = Class.new do
    include ElectricSheep::Metadata::Metered
  end

  describe MeteredKlazz do
    it 'benchmarks the execution time' do
      metered = subject.new.benchmarked do
        sleep 0.01
      end
      metered.execution_time.must_be :>=, 10 / 1000
    end
  end
end