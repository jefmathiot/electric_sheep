require 'spec_helper'
require 'net/ssh/test'

describe ElectricSheep::Transports::SCP do

    before do
      @logger = Logger.new(STDOUT)

      @project = ElectricSheep::Metadata::Project.new(id: "remote")
      @metadata = ElectricSheep::Metadata::Transport.new
      @hosts = mock
      #@hosts.stubs(:get).returns(toto)
      @subject = subject.new(@project, @logger, @metadata, @hosts)
      @subject.stubs(:option).with(:as).returns(@as = "user")
      @resource = ElectricSheep::Resources::FileSystem.new(path:'origin/filename.ext')
      @subject.stubs(:resource).returns( @resource )
    end

    #redefine in_remote_session for testing purpose
    class ElectricSheep::Transports::SCP
      def in_remote_session(host, &block)
          block.call $ssh
      end
    end
    describe 'on transport' do

      before do
          expects_open_and_close_shell
      end

      describe 'remote to local' do
        before do
          @subject.stubs(:option).with(:to).returns(@to = 'localhost')
          @hosts.stubs(:get).with('localhost').returns(ElectricSheep::Metadata::Localhost.new)
          @resource.stubs(:host).returns(ElectricSheep::Metadata::Host.new(id:'remote'))

          ensure_target_folder_exist(@local_shell)

          @remote_shell.stubs(:expand_path).with('origin/filename.ext').returns 'origin/filename.ext'
          @local_shell.stubs(:expand_path).with('filename.ext').returns 'filename.ext'
          expects_scp_cmp_with(@remote_shell,:download!,'origin/filename.ext','filename.ext')
        end

        it "should copy" do
          should_log_msg(:copy, 'remote','localhost')
          @subject.copy
        end

        it "should move" do
          should_log_msg(:move, 'remote', 'localhost')
          @remote_shell.expects(:exec).with( "rm -f origin/filename.ext").returns true
          @subject.move
        end
      end

      describe 'local to remote' do
        before do
          @to = ElectricSheep::Metadata::Host.new(id:'remote')
          @subject.stubs(:option).with(:to).returns('remote')
          @hosts.stubs(:get).with('remote').returns(@to)
          @resource.stubs(:host).returns(ElectricSheep::Metadata::Localhost.new)
          ensure_target_folder_exist(@remote_shell)
          @local_shell.stubs(:expand_path).with('origin/filename.ext').returns 'origin/filename.ext'
          @remote_shell.stubs(:expand_path).with('filename.ext').returns 'filename.ext'
          expects_scp_cmp_with(@remote_shell,:upload!,'origin/filename.ext','filename.ext')
        end

        it "should copy" do
          should_log_msg(:copy, 'localhost', 'remote')
          @subject.copy
        end

        it "should move" do
          should_log_msg(:move, 'localhost', 'remote')
          @local_shell.expects(:exec).with( "rm -f origin/filename.ext").returns true
          @subject.move
        end
      end
    end

    def expects_scp_cmp_with(shell, cmd, origin, target)
      shell.expects(:session).returns(session = mock)
      session.expects(:scp).returns(scp = mock)
      scp.expects(cmd).with(origin,target, verbose: true)
    end

    def ensure_target_folder_exist(shell)
      shell.expects(:mk_project_directory!)
    end

    def expects_open_and_close_shell
      ElectricSheep::Shell::LocalShell.expects(:new).returns(@local_shell=mock)
      ElectricSheep::Shell::RemoteShell.expects(:new).returns(@remote_shell=mock)
      @local_shell.expects(:open!).returns(@local_shell)
      @remote_shell.expects(:open!).returns(@remote_shell)
      @local_shell.expects(:close!).returns(@local_shell)
      @remote_shell.expects(:close!).returns(@remote_shell)
    end

    def should_log_msg(type, from, to)
      @logger.expects(:info).
        with("Will #{type} filename.ext from #{from} to #{to} using SCP")
    end
end
