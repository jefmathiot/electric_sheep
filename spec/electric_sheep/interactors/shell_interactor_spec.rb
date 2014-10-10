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
      session.expects(:exit_status).returns(err ? 2:1)
      logger.expects(:info).with('Output') if out
      logger.expects(:error).with('Error') if err
      if err
        proc{interactor.exec('ls')}.must_raise RuntimeError
      else
        result=interactor.exec('ls')
        result[:out].must_equal out || ''
        result[:err].must_equal err || ''
        result[:exit_status].must_equal 1
      end
    end

    it 'returns the out, err and exit status' do
        expects_execution "Output", "Error"
    end

    it 'doesnt log unless out, err and exit status' do
        expects_execution nil, nil
    end

  end

end
