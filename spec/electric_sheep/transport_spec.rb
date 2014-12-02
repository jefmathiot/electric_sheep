require 'spec_helper'

describe ElectricSheep::Transport do

  let(:project){ ElectricSheep::Metadata::Project.new(id: 'some-project') }

  let(:hosts){ ElectricSheep::Metadata::Hosts.new }

  let(:transport){ subject.new(project, logger, metadata, hosts) }

  [:local_interactor, :logger, :metadata].each do |m|
    let(m){ mock }
  end

  let(:seq){ sequence('run') }

  let(:resource) do
    mock.tap do |resource|
      resource.stubs(:name).returns('resource.name')
    end
  end

  let(:remote_host){
    mock.tap do |resource|
      resource.stubs(:local?).returns(false)
    end
  }

  let(:localhost){ ElectricSheep::Metadata::Hosts.new.localhost }

  module RemoteInteractor
    def remote_interactor
      interactor=Class.new do
        def in_session(&block)
          yield
        end
      end
      @remote_interactor ||= interactor.new
    end
  end

  module RemoteResource
    def remote_resource
      @remote_resource ||= Object.new
    end
  end

  NoRemoteResourceTransportKlazz = Class.new do
    include ElectricSheep::Transport
    include RemoteInteractor
    def self.required_method
      "remote_resource"
    end
  end

  NoRemoteInteractorTransportKlazz = Class.new do
    include ElectricSheep::Transport
    include RemoteResource
    def self.required_method
      "remote_interactor"
    end
  end

  TransportKlazz = Class.new do
    include ElectricSheep::Transport
    include RemoteInteractor
    include RemoteResource

    attr_reader :done

  end

  before do
    ElectricSheep::Interactors::ShellInteractor.expects(:new).with(
      hosts.localhost, project, logger
    ).returns( local_interactor )
    local_interactor.expects(:in_session).in_sequence(seq).yields
    project.stubs(:last_product).returns(resource)
    hosts.stubs(:get).with('some-host').returns(remote_host)
    hosts.stubs(:get).with('localhost').returns(localhost)
    metadata.stubs(:transport).returns('airplane')
  end

  [NoRemoteResourceTransportKlazz, NoRemoteInteractorTransportKlazz].each do |klazz|
    describe klazz do
      it 'complains remote_interactor is not implemented' do
        metadata.stubs(:to).returns('some-host')
        metadata.stubs(:type).returns('copy')
        resource.stubs(:local?).returns(true)
        logger.stubs(:info)
        transport.stubs(:stat!)
        ex = ->{transport.run!}.must_raise RuntimeError
        ex.message.must_equal "Not implemented, please define " +
          "#{klazz}##{klazz.required_method}"
      end
    end
  end


  describe TransportKlazz do

    {move: 'Moving', copy: 'Copying'}.each do |type, msg|

      def expects_delete(interactor, type)
        return if type==:copy
        interactor.expects(:delete!).in_sequence(seq).
          with(resource)
      end

      def expects_done(output, type)
        project.expects(:store_product!).in_sequence(seq).
          with(type==:copy ? resource : output)
      end

      describe "#{msg.downcase} a resource" do

        before do
          transport.remote_interactor.expects(:in_session).in_sequence(seq).yields
          metadata.stubs(:type).returns(type)
        end

        it 'transfers from local to remote' do
          metadata.stubs(:to).returns('some-host')
          resource.stubs(:local?).returns(true)
          transport.remote_resource.stubs(:local?).returns(false)
          logger.expects(:info).in_sequence(seq).
            with("#{msg} resource.name to some-host using airplane")
          transport.expects(:stat!).in_sequence(seq).
            with(resource, local_interactor)
          transport.remote_interactor.expects(:upload!).in_sequence(seq).
            with(resource, transport.remote_resource, local_interactor)
          expects_delete(local_interactor, type)
          transport.expects(:stat!).in_sequence(seq).
            with(transport.remote_resource, transport.remote_interactor)
          expects_done(transport.remote_resource, type)
          transport.run!
        end

        it 'transfers from remote to local' do
          metadata.stubs(:to).returns('localhost')
          resource.stubs(:local?).returns(false)
          transport.expects(:file_resource).with(localhost).returns(output=mock)
          output.stubs(:local?).returns(true)
          logger.expects(:info).in_sequence(seq).
            with("#{msg} resource.name to localhost using airplane")
          transport.expects(:stat!).in_sequence(seq).
            with(resource, transport.remote_interactor)
          transport.remote_interactor.expects(:download!).in_sequence(seq).
            with(resource, output, local_interactor)
          expects_delete(transport.remote_interactor, type)
          transport.expects(:stat!).in_sequence(seq).
            with(output, local_interactor)
          expects_done(output, type)
          transport.run!
        end

      end

    end

  end

end
