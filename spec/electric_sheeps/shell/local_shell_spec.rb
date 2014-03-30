require 'spec_helper'

describe ElectricSheeps::Shell::LocalShell do

  before do
    @logger = mock()
  end

  it 'indicates its type' do
    subject.new(nil).tap do |shell|
      shell.local?.must_equal true
      shell.remote?.must_equal false
    end
  end

  describe "with a session" do

    before do
      @logger.expects(:info).with("Starting a local shell session")
      @shell = subject.new( @logger )
      @shell.open!
    end

    it "should have open a shell session" do
      @shell.opened?.must_equal true
      @shell.instance_variable_get(:@session).must_be_instance_of( ::Session::Sh )
    end

    it 'should output stdout to logger' do
      @logger.expects(:info).with('Hello World')
      @logger.expects(:error).never
      @shell.exec 'echo "Hello World"'
    end

    it 'should output stderr to logger' do
      @logger.expects(:error).with('Goodbye Cruel World')
      @logger.expects(:info).never
      @shell.exec 'echo "Goodbye Cruel World" >&2'
    end

    it 'should output both stdout and stderr to logger' do
      @logger.expects(:info).with('Hello World')
      @logger.expects(:error).with('Goodbye Cruel World')
      @shell.exec 'echo "Hello World" ; echo "Goodbye Cruel World" >&2'
    end

    it 'should keep state when multiple calls' do
      @logger.expects(:info).with('/')
      @shell.exec 'cd /'
      @shell.exec 'pwd'
    end

    it 'should close' do
      @shell.close!.opened?.must_equal false
    end

    it 'should not try to reopen' do
      @shell.open!
    end

    describe 'on returning status' do
      it 'should succeed' do
        @logger.expects(:info).with('Hello World')
        @logger.expects(:error).never
        @shell.exec('echo "Hello World"').must_equal 0
      end

      it 'should fail gracefully' do
        @logger.expects(:info).never
        @logger.expects(:error).at_least_once
        @shell.exec('ls --wtf').must_equal 2
      end
    end

  end
end
