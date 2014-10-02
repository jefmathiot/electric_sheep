require 'spec_helper'
require 'net/ssh/test'

describe ElectricSheep::Transports::SCP do

  let:localhost do
    ElectricSheep::Metadata::Localhost.new
  end

  let :remote_host do
    ElectricSheep::Metadata::Host.new
  end

  let :remote_file do
    ElectricSheep::Resources::File.new(
      host: remote_host, path: "local/path"
    )
  end

  let :local_file do
    ElectricSheep::Resources::File.new(
      host: localhost, path: "remote/path"
    )
  end

  let :operation_opts do
    Struct.new(:resource, :interactor)
  end

  describe 'with an scp transport' do
    
    let :logger do
      mock
    end

    let :project do
      ElectricSheep::Metadata::Project.new(id: "remote")
    end

    let :metadata do
      ElectricSheep::Metadata::Transport.new
    end
    let :hosts do
      ElectricSheep::Metadata::Hosts.new
    end

    let :transport do
      subject.new(project, logger, metadata, hosts)
    end

    it 'delegates "copy" to operate' do
      transport.expects(:operate).with(:copy)
      transport.copy
    end

    it 'delegates "move" to operate' do
      transport.expects(:operate).with(:move)
      transport.move
    end

    it 'retrieves the local interactor' do
      transport.send(:interactor_for, hosts.localhost).must_equal transport.send(:local_interactor)
    end

    it 'creates a remote interactor' do
      remote_host = mock
      remote_host.expects(:local?).returns(false)
      ElectricSheep::Interactors::SshInteractor.expects(:new).
        with(remote_host, project, nil).
        returns(interactor = mock)
      transport.send(:interactor_for, remote_host).must_equal interactor
    end

    describe 'operating' do

      before do
        transport.stubs(:resource).returns(local_file)
      end

      it 'tries to visit available operations' do
        retrieve_hosts
        retrieve_interactors
        [
          ElectricSheep::Transports::SCP::DownloadOperation,
          ElectricSheep::Transports::SCP::UploadOperation
        ].each do |klazz|
          instance = klazz.any_instance
          instance.expects(:perform).with(false)
        end
        transport.send(:operate, :toto)
      end

      def retrieve_hosts
        transport.expects(:option).with(:to).returns("from")
        transport.expects(:host).with("from").returns(remote_host)
      end

      def retrieve_interactors
        transport.expects(:interactor_for).with(remote_host).
          returns(@from_interactor = mock )
        transport.expects(:interactor_for).with(localhost).
          returns(@to_interactor = mock )
      end
    end

    describe ElectricSheep::Transports::SCP::Operation do

      before do
        @from = operation_opts.new(local_file, 'finteractor')
        @to = operation_opts.new(remote_file, 'tinteractor')
        @operation = subject.new(from: @from, to: @to)
      end

      it 'returns "from" attribute' do
        @operation.from.must_equal @from
      end

      it 'returns "to" attribute' do
        @operation.to.must_equal @to
      end

      describe 'on building result' do
        it 'returns "to" if delete_source option' do
          @operation.result(remote_file, local_file, true).must_equal [
            @to.resource.host, remote_file
          ]
        end
        it 'returns "from" unless delete_source option' do
          @operation.result(remote_file, local_file, false).must_equal [
            @from.resource.host, local_file
          ]
        end
      end

      it 'calls the right scp method' do
        target, scp, interactor = mock, mock, mock
        target.expects(:interactor).returns(interactor)
        interactor.expects(:scp).returns(scp)

        @from.interactor.expects(:expand_path).with("remote/path").returns('from_path')
        @to.interactor.expects(:expand_path).with("local/path").returns('to_path')

        scp.expects(:send).with('cmd!', "from_path", "to_path", {:recursive => false})
        @operation.copy(target, :cmd)
      end


      describe ElectricSheep::Transports::SCP::UploadOperation do

        class ElectricSheep::Interactors::SshInteractor
          def in_session(&block)
            block.call
          end
        end

        before do
          @interactor = ElectricSheep::Interactors::SshInteractor.new(nil, nil, nil)
        end

        describe 'with inconsistent resources' do

          before do
            @from = operation_opts.new(local_file, 'finteractor' )
            @to = operation_opts.new(local_file, 'tinteractor' )
            @operation = subject.new(from: @from, to: @to)
          end

          it 'does nothing' do
            @operation.perform(true).must_equal nil
          end

        end

        describe 'with consistent resources' do

          before do
            @from = operation_opts.new(local_file, @interactor)
            @to   = operation_opts.new(remote_file, @interactor)
            @operation = subject.new(from: @from, to: @to)
          end

          it 'uploads the file' do
            @operation.expects(:copy).with(@to, :upload)
            @operation.perform(false) do |host, path|
              host.must_equal localhost
              path.must_equal nil
            end
          end

          it 'uploads the file and deletes the original one' do
            @operation.expects(:copy).with(@to,:upload)
            @from.interactor.expects(:exec).with("rm -rf ")
            @operation.perform(true) do |host, path|
              host.must_equal remote_host
              path.must_equal nil
            end
          end

        end

      end

      describe ElectricSheep::Transports::SCP::DownloadOperation do

        class ElectricSheep::Interactors::SshInteractor
          def in_session(&block)
            block.call
          end
        end

        before do
          @interactor = ElectricSheep::Interactors::SshInteractor.new(nil, nil, nil)
        end

        describe 'with inconsistent resources' do

          before do
            @from = operation_opts.new(local_file, @interactor)
            @to = operation_opts.new(local_file, @interactor)
            @operation = subject.new(from: @from, to: @to)
          end

          it 'does nothing' do
            @operation.perform(true).must_equal nil
          end

        end

        describe 'with consistent resources' do

          before do
            @from = operation_opts.new(remote_file, @interactor)
            @to   = operation_opts.new(local_file, @interactor)
            @operation = subject.new( from: @from, to: @to)
          end

          it 'downloads the file' do
            @operation.expects(:copy).with(@from,:download)
            @operation.perform(false) do |host, path|
              host.must_equal remote_host
              path.must_equal nil
            end
          end

          it 'upload file and remove origin file' do
            @operation.expects(:copy).with(@from, :download)
            @from.interactor.expects(:exec).with("rm -rf ")
            @operation.perform(true) do |host, path|
              host.must_equal localhost
              path.must_equal nil
            end
          end

        end

      end

    end

  end

end
