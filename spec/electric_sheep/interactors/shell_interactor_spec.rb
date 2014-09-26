require 'spec_helper'

describe ElectricSheep::Interactors::ShellInteractor do
  [:host, :project, :logger].each do |var|
    let(var) do
      mock
    end
  end

  let(:interactor) do
    subject.new(host, project, logger)
  end

  it 'builds a session' do
    interactor.send(:build_session).must_be_instance_of ::Session::Sh
  end

  describe 'executing a command' do

    def expects_execution(out, err)
      interactor.stubs(:session).returns(session=mock)
      session.expects(:execute).with('ls').
        yields(out && "#{out}\n", err && "#{err}\n")
      logger.expects(:info).with('Output') if out
      logger.expects(:error).with('Error') if err
      session.expects(:exit_status).returns(1)
      result=interactor.exec('ls')
      result[:out].must_equal out || ''
      result[:err].must_equal err || ''
      result[:exit_status].must_equal 1
    end

    it 'returns the out, err and exit status' do
        expects_execution "Output", "Error"
    end
    
    it 'doesnt log unless out, err and exit status' do
        expects_execution nil, nil
    end

  end
  #  before do
  #    @host, @logger, @project = mock, mock, mock
  #    @shell=subject.new(@host, @project, @logger)
  #  end
  #
  #  it 'indicates its type' do
  #    @shell.local?.must_equal true
  #    @shell.remote?.must_equal false
  #  end
  #
  #  describe "with a session" do
  #
  #    before do
  #      @logger.expects(:info).with("Starting a local shell session")
  #      @shell.open!
  #    end
  #
  #    it "should have open a shell session" do
  #      @shell.opened?.must_equal true
  #      @shell.instance_variable_get(:@interactor).session.must_be_instance_of( ::Session::Sh )
  #    end
  #
  #    it 'should output stdout to logger' do
  #      @logger.expects(:info).with('Hello World')
  #      @logger.expects(:error).never
  #      @shell.exec 'echo "Hello World"'
  #    end
  #
  #    it 'should output stderr to logger' do
  #      @logger.expects(:error).with('Goodbye Cruel World')
  #      @logger.expects(:info).never
  #      @shell.exec 'echo "Goodbye Cruel World" >&2'
  #    end
  #
  #    it 'should output both stdout and stderr to logger' do
  #      @logger.expects(:info).with('Hello World')
  #      @logger.expects(:error).with('Goodbye Cruel World')
  #      @shell.exec 'echo "Hello World" ; echo "Goodbye Cruel World" >&2'
  #    end
  #
  #    it 'should keep state when multiple calls' do
  #      @logger.expects(:info).with('/')
  #      @shell.exec 'cd /'
  #      @shell.exec 'pwd'
  #    end
  #
  #    it 'should close' do
  #      @shell.close!.opened?.must_equal false
  #    end
  #
  #    it 'should not try to reopen' do
  #      @shell.open!
  #    end
  #
  #    describe 'on returning status' do
  #
  #      it 'should succeed' do
  #        @logger.expects(:info).with('Hello World')
  #        @logger.expects(:error).never
  #        result = @shell.exec('echo "Hello World"')
  #        result[:exit_status].must_equal 0
  #        result[:out].must_equal 'Hello World'
  #      end
  #
  #      it 'should fail gracefully' do
  #        @logger.expects(:info).never
  #        @logger.expects(:error).at_least_once
  #        result = @shell.exec('echo "Goodbye Cruel World" >&2 && false')
  #        result[:exit_status].must_equal 1
  #        result[:err].must_equal 'Goodbye Cruel World'
  #      end
  #    end
  #
  #  end
end
