require 'spec_helper'
require 'net/ssh/test'

describe ElectricSheep::Transports::SCP do


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
          @subject.stubs(:resource).returns(@resource=mock)
          @resource.stubs(:host).returns(@to_host=mock)
          @resource.stubs(:basename).returns("basename")
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
          @subject.expects(:host).with("from").returns(@from_host=mock)
        end

        def retrieve_interactors
          @subject.expects(:interactor_for).with(@from_host).returns(@from_interactor = mock )
          @subject.expects(:interactor_for).with(@to_host).returns(@to_interactor = mock )
        end
      end

      describe 'class Operation' do

        before do
          oo = Struct.new(:host, :interactor, :file)
          @from = oo.new('fost','finteractor','file')
          @to   = oo.new('tost','tinteractor','tile')
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
            @operation.result('target','source',true).must_equal [@to.host,'target']
          end
          it 'return "from" on undeleted source' do
            @operation.result('target','source',false).must_equal [@from.host,'source']
          end
        end

        it 'call good scp command on scp_cmd' do
          target, scp, interactor = mock, mock, mock
          target.expects(:interactor).returns(interactor)
          interactor.expects(:scp).returns(scp)

          @from.file.expects(:path).returns('from_path')
          @to.file.expects(:path).returns('to_path')

          @from.interactor.expects(:expand_path).with("from_path").returns('from_path/')
          @to.interactor.expects(:expand_path).with("to_path").returns('to_path/')

          scp.expects(:send).with(:cmd,"from_path/","to_path/")
          @operation.scp_cmd(target,:cmd)
        end


      describe 'class UploadOperation' do

        class ElectricSheep::Interactors::SshInteractor
          def in_session(&block)
            block.call
          end
        end

        before do
          @interactor = ElectricSheep::Interactors::SshInteractor.new(nil,nil,nil)
          @local_host = ElectricSheep::Metadata::Localhost.new
          @remote_host = ElectricSheep::Metadata::Host.new
        end

        describe 'on invalid data' do
          before do
            oo = Struct.new(:host, :interactor, :file)
            @from = oo.new(@local_host,'finteractor','file')
            @to   = oo.new(@local_host,'tinteractor','tile')
            @operation = ElectricSheep::Transports::SCP::UploadOperation.new({from:@from,to:@to})
          end
          it 'do nothing' do
            @operation.perform(true).must_equal false
          end
        end

        describe 'on valid data' do
          before do
            oo = Struct.new(:host, :interactor, :file)
            @from = oo.new(@local_host, @interactor,'file')
            @to   = oo.new(@remote_host, @interactor,'tile')
            @operation = ElectricSheep::Transports::SCP::UploadOperation.new({from:@from,to:@to})
          end
          it 'upload file' do
            @operation.expects(:scp_cmd).with(@to,:upload!)
            @operation.perform(false) do |host,path|
              host.must_equal @local_host
              path.must_equal nil
            end
          end
          it 'upload file and remove origin file' do
            @operation.expects(:scp_cmd).with(@to,:upload!)
            @from.interactor.expects(:exec).with("rm -f ")
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
          @local_host = ElectricSheep::Metadata::Localhost.new
          @remote_host = ElectricSheep::Metadata::Host.new
        end

        describe 'on invalid data' do
          before do
            oo = Struct.new(:host, :interactor, :file)
            @from = oo.new(@local_host,'finteractor','file')
            @to   = oo.new(@local_host,'tinteractor','tile')
            @operation = ElectricSheep::Transports::SCP::DownloadOperation.new({from:@from,to:@to})
          end
          it 'do nothing' do
            @operation.perform(true).must_equal false
          end
        end

        describe 'on valid data' do
          before do
            oo = Struct.new(:host, :interactor, :file)
            @from = oo.new(@remote_host, @interactor,'file')
            @to   = oo.new(@local_host, @interactor,'tile')
            @operation = ElectricSheep::Transports::SCP::DownloadOperation.new({from:@from,to:@to})
          end
          it 'upload file' do
            @operation.expects(:scp_cmd).with(@from,:download!)
            @operation.perform(false) do |host,path|
              host.must_equal @remote_host
              path.must_equal nil
            end
          end
          it 'upload file and remove origin file' do
            @operation.expects(:scp_cmd).with(@from,:download!)
            @from.interactor.expects(:exec).with("rm -f ")
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
