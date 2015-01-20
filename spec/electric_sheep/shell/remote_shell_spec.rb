require 'spec_helper'
require 'net/ssh/test'

describe ElectricSheep::Shell::RemoteShell do
  [:host, :job, :input, :logger].each do |var|
    let(var) do
      mock
    end
  end

  let(:shell) do
    subject.new(host, job, input, logger, 'johndoe')
  end

  it 'initializes an interactor and cache it' do
    ElectricSheep::Interactors::SshInteractor.expects(:new).
      with(host, job, 'johndoe', logger).once.returns(interactor=mock)
    2.times do
      shell.send(:interactor).must_equal interactor
    end
  end

  it 'logs and performs' do
    shell.instance_variable_set(:@interactor, mock)
    shell.send(:interactor).expects(:in_session) # Don't mock "super"
    host.expects(:hostname).returns('some-host')
    host.expects(:ssh_port).returns(22)
    logger.expects(:info).with("Starting a remote shell session for johndoe@some-host on port 22")
    shell.perform!(metadata=mock)
  end
end
