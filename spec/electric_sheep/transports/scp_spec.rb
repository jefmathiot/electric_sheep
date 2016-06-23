require 'spec_helper'
require 'net/ssh/test'

describe ElectricSheep::Transports::SCP do
  include Support::Transport
  include Support::Options

  it { defines_options :as }

  describe 'creating a remote interactor' do
    before do
      metadata.stubs(:as).returns('user')
      metadata.stubs(:to).returns('some-host')
    end

    let(:input) { mock }

    let(:interactor_klazz) { ElectricSheep::Interactors::SshInteractor }

    let(:scp) { subject.new(job, logger, hosts, input, metadata) }

    it 'creates an SSH interactor referencing to the provided host' do
      input.stubs(:local?).returns(true)
      metadata.stubs(:as).returns('user')
      scp.expects(:host).with('some-host').returns(host = mock)
      interactor_klazz
        .expects(:new).with(host, job, 'user', logger)
        .returns(interactor = Object.new)
      scp.remote_interactor.must_equal interactor
    end

    it 'creates an SSH interactor referencing the host of the input resource' do
      input.stubs(:local?).returns(false)
      input.expects(:host).returns(host = mock)
      interactor_klazz
        .expects(:new).with(host, job, 'user', logger)
        .returns(interactor = Object.new)
      scp.remote_interactor.must_equal interactor
    end

    it 'builds a remote resource' do
      input.stubs(:type).returns('file')
      scp.expects(:host).with('some-host').returns(host = mock)
      scp.expects(:file_resource).with(host).returns(output = mock)
      scp.remote_resource.must_equal output
    end

    it 'should have registered as the "scp" transport' do
      ElectricSheep::Agents::Register.transport('scp').must_equal subject
    end
  end
end
