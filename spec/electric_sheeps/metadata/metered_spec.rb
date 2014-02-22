require 'spec_helper'

describe ElectricSheeps::Metadata::Metered do
    Klazz = Class.new do
        include ElectricSheeps::Metadata::Metered
    end

    describe Klazz do
        it 'benchmarks the execution time' do
            metered = subject.new.benchmarked do
                sleep 0.01
            end
            metered.execution_time.must_be :>=, 10 / 1000
        end
    end
end