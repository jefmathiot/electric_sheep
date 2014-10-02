require 'spec_helper'
require 'net/ssh/test'

describe ElectricSheep::Transports::SCP do

    before do
      @local_host = ElectricSheep::Metadata::Localhost.new
      @remote_host = ElectricSheep::Metadata::Host.new
      @remote_resource = ElectricSheep::Resources::File.new(host:@remote_host,path:"local_file_path")
      @local_resource  = ElectricSheep::Resources::File.new(host:@local_host,path:"remote_file_path")
    end

    describe 'with a scp transport' do
      before do
        @logger = Logger.new(STDOUT)
        @project = ElectricSheep::Metadata::Project.new(id: "remote")
        @metadata = ElectricSheep::Metadata::Transport.new
        @hosts = ElectricSheep::Metadata::Hosts.new
        @subject = subject.new(@project, @logger, @metadata, @hosts)
      end

      it 'delegate "copy" to operate' do
        @subject.expects(:operate).with(:copy)
        @subject.copy
      end

      it 'delegate "move" to operate' do
        @subject.expects(:operate).with(:move)
        @subject.move
      end

      it 'retrive local interactor' do
        @subject.send(:interactor_for, @hosts.localhost).must_equal @subject.send(:local_interactor)
      end

      it 'retrive remote interactor' do
        remote_host = mock
        remote_host.expects(:local?).returns(false)
        ElectricSheep::Interactors::SshInteractor.expects(:new).with(remote_host,@project,nil).returns(interactor = mock)
        @subject.send(:interactor_for, remote_host).must_equal interactor
      end

      describe 'operate' do
        before do
          @subject.stubs(:resource).returns(@local_resource)
        end
        it 'try to perform all operations type' do
          retrieve_hosts
          retrieve_interactors
          [
            ElectricSheep::Transports::SCP::DownloadOperation,
            ElectricSheep::Transports::SCP::UploadOperation
          ].each do |klazz|
            instance = klazz.any_instance
            instance.expects(:perform).with(false)
          end
          @subject.send(:operate, :toto)
        end

        def retrieve_hosts
          @subject.expects(:option).with(:to).returns("from")
          @subject.expects(:host).with("from").returns(@remote_host)
        end

        def retrieve_interactors
          @subject.expects(:interactor_for).with(@remote_host).returns(@from_interactor = mock )
          @subject.expects(:interactor_for).with(@local_host).returns(@to_interactor = mock )
        end
      end

      describe 'class Operation' do

        before do
          oo = Struct.new(:resource, :interactor)
          @from = oo.new(@local_resource,'finteractor')
          @to   = oo.new(@remote_resource,'tinteractor')
          @operation = ElectricSheep::Transports::SCP::Operation.new({from:@from,to:@to})
        end

        it 'return "from" attribute' do
          @operation.from.must_equal @from
        end

        it 'return "to" attribute' do
          @operation.to.must_equal @to
        end

        describe 'on result function' do
          it 'return "to" on deleted source' do
            @operation.result(@remote_resource, @local_resource,true).must_equal [@to.resource.host,@remote_resource]
          end
          it 'return "from" on undeleted source' do
            @operation.result(@remote_resource, @local_resource,false).must_equal [@from.resource.host,@local_resource]
          end
        end

        it 'call good scp command on copy' do
          target, scp, interactor = mock, mock, mock
          target.expects(:interactor).returns(interactor)
          interactor.expects(:scp).returns(scp)

          @from.interactor.expects(:expand_path).with("remote_file_path").returns('from_path/')
          @to.interactor.expects(:expand_path).with("local_file_path").returns('to_path/')

          scp.expects(:send).with('cmd!',"from_path/","to_path/", {:recursive => false})
          @operation.copy(target,:cmd)
        end


      describe 'class UploadOperation' do

        class ElectricSheep::Interactors::SshInteractor
          def in_session(&block)
            block.call
          end
        end

        before do
          @interactor = ElectricSheep::Interactors::SshInteractor.new(nil,nil,nil)
        end

        describe 'on invalid data' do
          before do
            oo = Struct.new(:resource, :interactor)
            @from = oo.new(@local_resource,'finteractor')
            @to   = oo.new(@local_resource,'tinteractor')
            @operation = ElectricSheep::Transports::SCP::UploadOperation.new({from:@from,to:@to})
          end
          it 'do nothing' do
            @operation.perform(true).must_equal nil
          end
        end

        describe 'on valid data' do

          before do
            oo = Struct.new(:resource, :interactor)
            @from = oo.new(@local_resource, @interactor)
            @to   = oo.new(@remote_resource, @interactor)
            @operation = ElectricSheep::Transports::SCP::UploadOperation.new({from:@from,to:@to})
          end

          it 'upload file' do
            @operation.expects(:copy).with(@to,:upload)
            @operation.perform(false) do |host,path|
              host.must_equal @local_host
              path.must_equal nil
            end
          end

          it 'upload file and remove origin file' do
            @operation.expects(:copy).with(@to,:upload)
            @from.interactor.expects(:exec).with("rm -rf ")
            @operation.perform(true) do |host,path|
              host.must_equal @remote_host
              path.must_equal nil
            end
          end
        end
      end

      describe 'class DownloadOperation' do

        class ElectricSheep::Interactors::SshInteractor
          def in_session(&block)
            block.call
          end
        end

        before do
          @interactor = ElectricSheep::Interactors::SshInteractor.new(nil,nil,nil)
        end

        describe 'on invalid data' do
          before do
            oo = Struct.new(:resource, :interactor)
            @from = oo.new(@local_resource, @interactor)
            @to   = oo.new(@local_resource, @interactor)
            @operation = ElectricSheep::Transports::SCP::DownloadOperation.new({from:@from,to:@to})
          end
          it 'do nothing' do
            @operation.perform(true).must_equal nil
          end
        end

        describe 'on valid data' do
          before do
            oo = Struct.new(:resource, :interactor)
            @from = oo.new(@remote_resource, @interactor)
            @to   = oo.new(@local_resource, @interactor)
            @operation = ElectricSheep::Transports::SCP::DownloadOperation.new({from:@from,to:@to})
          end
          it 'upload file' do
            @operation.expects(:copy).with(@from,:download)
            @operation.perform(false) do |host,path|
              host.must_equal @remote_host
              path.must_equal nil
            end
          end
          it 'upload file and remove origin file' do
            @operation.expects(:copy).with(@from,:download)
            @from.interactor.expects(:exec).with("rm -rf ")
            @operation.perform(true) do |host,path|
              host.must_equal @local_host
              path.must_equal nil
            end
          end
        end
      end
    end
  end
end
