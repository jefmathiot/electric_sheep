require 'spec_helper'
require 'net/ssh/test'

describe ElectricSheep::Transports::SCP do
  include Support::Transport

  before do
    project.stubs(:last_product).returns(resource)
    metadata.stubs(:as).returns('user')
    metadata.stubs(:to).returns('some-host')
  end

  describe 'creating a remote interactor' do

    let(:interactor_klazz){ ElectricSheep::Interactors::SshInteractor }

    let(:scp){ subject.new(project, logger, metadata, hosts) }

    it 'creates an SSH interactor referencing to the provided host' do
      resource.stubs(:local?).returns(true)
      metadata.stubs(:as).returns('user')
      scp.expects(:host).with('some-host').returns(host=mock)
      interactor_klazz.expects(:new).with(host, project, 'user', logger).
        returns(interactor=Object.new)
      scp.remote_interactor.must_equal interactor
    end

    it 'creates an SSH interactor referencing the host of the input resource' do
      resource.stubs(:local?).returns(false)
      resource.expects(:host).returns(host=mock)
      interactor_klazz.expects(:new).with(host, project, 'user', logger).
        returns(interactor=Object.new)
      scp.remote_interactor.must_equal interactor
    end

    it 'builds a remote resource' do
      resource.stubs(:type).returns('file')
      scp.expects(:host).with('some-host').returns(host=mock)
      scp.expects(:file_resource).with(host).returns(output=mock)
      scp.remote_resource.must_equal output
    end

  end

end
