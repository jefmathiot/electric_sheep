require 'spec_helper'

describe ElectricSheep::Shell::Base do
  [:host, :project, :logger].each do |var|
    let(var) do
      mock
    end
  end

  let(:shell) do
    subject.new(host, project, logger).tap do |shell|
      shell.instance_variable_set(:@interactor, mock)
    end
  end

  it 'delegates path expansion to interactor' do
    shell.interactor.expects(:expand_path).with('some/path')
    shell.expand_path('some/path')
  end

  it 'identifies localhost' do
    host.expects(:local?).twice.returns true
    shell.local?.must_equal true
    shell.remote?.must_equal false
  end

  it 'identifies a remote host' do
    host.expects(:local?).twice.returns false
    shell.local?.must_equal false
    shell.remote?.must_equal true
  end

  class FakeCommand
    include ElectricSheep::Command

    register as: :fake
  end

  it 'performs the queue of commands' do
    metadata=ElectricSheep::Metadata::Shell.new
    metadata.add ElectricSheep::Metadata::Command.new(
      id: 'first', type: 'fake'
    )
    metadata.add ElectricSheep::Metadata::Command.new(
      id: 'second', type: 'fake'
    )
    shell.interactor.expects(:in_session).yields
    ElectricSheep::Metadata::Command.any_instance.expects(:benchmarked).
      twice.yields
    FakeCommand.any_instance.tap do |cmd|
      cmd.expects(:check_prerequisites).twice
      cmd.expects(:run!).twice
    end
    shell.perform!(metadata)
  end
end
