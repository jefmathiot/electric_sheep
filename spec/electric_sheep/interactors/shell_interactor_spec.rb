require 'spec_helper'

describe ElectricSheep::Interactors::ShellInteractor do
  [:host, :job, :logger].each do |var|
    let(var) do
      mock
    end
  end

  let(:interactor) do
    subject.new(host, job, logger)
  end

  it 'builds a session' do
    interactor.send(:build_session).must_be_nil
  end

  describe 'executing a command' do
    def expects_execution(cmd, out = '', err = '')
      logger.stubs(:debug)
      ElectricSheep::Spawn
        .expects(:exec).with(cmd, logger)
        .returns(out: out, err: err, exit_status: err ? 2 : 0)
      if err
        proc { interactor.exec(cmd) }.must_raise RuntimeError
      else
        result = interactor.exec(cmd)
        result[:out].must_equal out || ''
        result[:err].must_equal err || ''
        result[:exit_status].must_equal 0
      end
    end

    it 'returns the out, err and exit status' do
      expects_execution 'ls', 'Output', 'Error'
    end

    it 'doesnt raise unless out, err and exit status' do
      expects_execution 'ls'
    end
  end

  it 'deletes a resource' do
    resource = mock(path: 'resource')
    cmd = 'rm -rf /path/to/resource'
    interactor.expects(:expand_path).with('resource')
              .returns('/path/to/resource')
    interactor.expects(:exec).with(cmd)
    interactor.delete!(resource)
  end
end
