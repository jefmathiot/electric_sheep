require 'spec_helper'

describe ElectricSheep::Shell::Base do
  [:host, :project, :logger, :input].each do |var|
    let(var) do
      mock
    end
  end

  let(:shell) do
    subject.new(host, project, input, logger).tap do |shell|
      shell.instance_variable_set(:@interactor, mock)
    end
  end

  let(:seq){sequence('shell')}

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
  end

  it 'performs the queue of commands' do
    metadata=ElectricSheep::Metadata::Shell.new
    first=metadata.add ElectricSheep::Metadata::Command.new(
      id: 'first', type: 'fake'
    )
    second=metadata.add ElectricSheep::Metadata::Command.new(
      id: 'second', type: 'fake'
    )
    shell.interactor.expects(:in_session).in_sequence(seq).yields
    metadata.expects(:pipelined).with(input, project).in_sequence(seq).
      multiple_yields [first, input], [second, input]
    [first, second].each do |cmd_metadata|
      cmd_metadata.stubs(:agent).returns(FakeCommand)
      ElectricSheep::Metadata::Command.any_instance.expects(:monitored).
        in_sequence(seq).yields
      FakeCommand.any_instance.tap do |cmd|
        cmd.expects(:run!).in_sequence(seq).returns(input)
      end
    end
    shell.perform!(metadata)
  end
end
