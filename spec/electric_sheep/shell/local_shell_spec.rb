require 'spec_helper'

describe ElectricSheep::Shell::LocalShell do

  before do
    @host, @logger, @project = mock, mock, mock
    @shell=subject.new(@host, @project, @logger)
  end

  it 'indicates its type' do
    @shell.local?.must_equal true
    @shell.remote?.must_equal false
  end

  describe "with a session" do

    before do
      @logger.expects(:info).with("Starting a local shell session")
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
        result = @shell.exec('echo "Hello World"')
        result[:exit_status].must_equal 0
        result[:out].must_equal 'Hello World'
      end

      it 'should fail gracefully' do
        @logger.expects(:info).never
        @logger.expects(:error).at_least_once
        result = @shell.exec('echo "Goodbye Cruel World" >&2 && false')
        result[:exit_status].must_equal 1
        result[:err].must_equal 'Goodbye Cruel World'
      end
    end

    describe 'on parse_env_variable' do

      it 'should parse variable correctly' do
        @shell.exec('export FOO=bar')
        @logger.expects(:info).with('/bar/baz')
        @shell.parse_env_variable('/$FOO/baz').must_equal '/bar/baz'
      end
    end

  end
end
