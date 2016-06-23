require 'spec_helper'

describe ElectricSheep::Metadata::Monitor do
  MonitorKlazz = Class.new do
    include ElectricSheep::Metadata::Monitor
  end

  describe MonitorKlazz do
    it 'benchmarks the execution time' do
      monitor = subject.new
      monitor.monitored do
        sleep 0.01
      end
      monitor.execution_time.must_be :>=, 10 / 1000
    end

    it 'returns whatever the provided block returned' do
      subject.new.monitored { 'whatever' }.must_equal 'whatever'
    end

    it 'handles exceptions gracefully' do
      monitor = subject.new
      ex = lambda do
        monitor.monitored do
          raise 'An exception'
        end
      end.must_raise RuntimeError
      ex.message.must_equal 'An exception'
      monitor.status.must_equal :failed
      monitor.failed?.must_equal true
    end

    it 'has no default status' do
      subject.new.successful?.must_equal false
      subject.new.failed?.must_equal false
    end

    it '\o/' do
      monitor = subject.new
      monitor.monitored {}
      monitor.successful?.must_equal true
    end
  end
end
