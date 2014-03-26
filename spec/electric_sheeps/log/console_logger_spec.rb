require 'spec_helper'

describe ElectricSheeps::Log::ConsoleLogger do

  describe 'with a single logger' do

    before do
      @out = mock
      @logger = subject.new(@out)
    end

    %w(info warn debug error fatal).each do |method|
      it "should redirect #{method} to out logger" do
        @out.expects(:puts).with('Hello World')
        @logger.send method, 'Hello World'
      end
    end

  end

  describe 'with distinct error and standard loggers' do

    before do
      @out = mock
      @err = mock
      @logger = subject.new(@out, @err)
    end

    %w(info warn debug).each do |method|
      it "should redirect #{method} to out logger" do
        @out.expects(:puts).with('Hello World')
        @err.expects(:puts).never
        @logger.send method, 'Hello World'
      end
    end

    %w(error fatal).each do |method|
      it "should redirect #{method} to err logger" do
        @err.expects(:puts).with('Goodbye Cruel World')
        @out.expects(:puts).never
        @logger.send method, 'Goodbye Cruel World'
      end
    end

  end
end
