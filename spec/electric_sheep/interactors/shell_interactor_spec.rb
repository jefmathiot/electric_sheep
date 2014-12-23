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

    def expects_execution(cmd, out=nil, err=nil)
      interactor.stubs(:session).returns(session=mock)
      session.expects(:execute).with(cmd).
        yields(out && "#{out}\n", err && "#{err}\n")
      session.expects(:exit_status).returns(err ? 2:0)
      logger.expects(:debug).with(cmd)
      if err
        proc{interactor.exec(cmd)}.must_raise RuntimeError
      else
        result=interactor.exec(cmd)
        result[:out].must_equal out || ''
        result[:err].must_equal err || ''
        result[:exit_status].must_equal 0
      end
    end

    it 'returns the out, err and exit status' do
      logger.expects(:debug).with('Output')
      expects_execution 'ls', "Output", "Error"
    end

    it 'doesnt log unless out, err and exit status' do
      expects_execution 'ls'
    end

  end

  it 'deletes a resource' do
    resource=mock(path: 'resource')
    cmd='rm -rf /path/to/resource'
    interactor.expects(:expand_path).with('resource').
      returns('/path/to/resource')
    interactor.expects(:exec).with(cmd)
    interactor.delete!(resource)
  end

end
