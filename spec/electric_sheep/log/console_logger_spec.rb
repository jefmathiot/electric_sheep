require 'spec_helper'

describe ElectricSheep::Log::ConsoleLogger do

  describe 'with a single logger' do

    before do
      @out = mock
      @logger = subject.new(@out)
    end

    %w(info warn error fatal success).each do |method|
      it "redirect #{method} to out logger" do
        @out.expects(:puts)
        @logger.send method, 'Hello World'
      end
    end

    %w(debug).each do |method|
      it "redirect #{method} to out logger" do
        @out.expects(:puts).never
        @logger.send method, 'Hello World'
      end
    end

  end

  describe 'with debug flag' do

    before do
      @out = mock
      @logger = subject.new(@out, @out, true)
    end

    %w(info warn error fatal success debug).each do |method|
      it "redirect #{method} to out logger" do
        @out.expects(:puts)
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

    %w(info warn).each do |method|
      it "redirect #{method} to out logger" do
        @out.expects(:puts)
        @err.expects(:puts).never
        @logger.send method, 'Hello World'
      end
    end

    %w(error fatal).each do |method|
      it "redirect #{method} to err logger" do
        @err.expects(:puts)
        @out.expects(:puts).never
        @logger.send method, 'Goodbye Cruel World'
      end
    end

    %w(debug).each do |method|
      it "redirect #{method} to out logger" do
        @out.expects(:puts).never
        @err.expects(:puts).never
        @logger.send method, 'Hello World'
      end
    end

  end

  describe 'prefix log message' do

    before do
      @out = mock
      @logger = subject.new(@out, @out, true)
    end

    %w(info warn error fatal success debug).each do |method|
      it "prefix #{method} with prefix" do
        prefix = {info:'',
                  warn:'[WARNING] '.blue,
                  error:'[ERROR] '.red,
                  fatal:'[ERROR] '.red,
                  success:'[SUCCESS] '.green,
                  debug:'[DEBUG] '.blue,}[method.to_sym]
        @out.expects(:puts).with(prefix << 'Hello World')
        @logger.send method, 'Hello World'
      end
    end
  end

end
