require 'spec_helper'

describe ElectricSheep::Shell::LocalShell do
  [:host, :job, :input, :logger].each do |var|
    let(var) do
      mock
    end
  end

  let(:shell) do
    subject.new(host, job, input, logger)
  end

  it 'initializes an interactor and cache it' do
    ElectricSheep::Interactors::ShellInteractor
      .expects(:new)
      .with(host, job, logger).once.returns(interactor = mock)
    2.times do
      shell.send(:interactor).must_equal interactor
    end
  end

  it 'logs and performs' do
    shell.instance_variable_set(:@interactor, mock)
    shell.send(:interactor).expects(:in_session) # Don't mock "super"
    logger.expects(:info).with('Starting a local shell session')
    shell.perform!(mock)
  end
end
