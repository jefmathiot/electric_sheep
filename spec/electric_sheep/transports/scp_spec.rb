require 'spec_helper'
require 'net/ssh/test'

describe ElectricSheep::Transports::SCP do

    before do
      @logger = mock
      @ssh = $ssh = mock
      @ssh.stubs(:scp).returns(@scp = mock)
      @shell = mock

      @project = ElectricSheep::Metadata::Project.new(id: "remote")
      @metadata = ElectricSheep::Metadata::Transport.new
      @hosts = mock
      #@hosts.stubs(:get).returns(toto)
      @meta_scp = subject.new(@project, @logger, @metadata, @hosts, @shell)
      @meta_scp.stubs(:option).with(:as).returns(@as = "user")
      @meta_scp.stubs(:resource).returns(@resource = mock)
    end

    #redefine in_remote_session for testing purpose
    class ElectricSheep::Transports::SCP
      def in_remote_session(host, &block)
          block.call $ssh
      end
    end

    describe 'remote to local' do
      before do
        @meta_scp.stubs(:option).with(:to).returns(@to = 'localhost')
        @hosts.stubs(:get).with('localhost').returns(ElectricSheep::Metadata::Localhost.new)
        @resource.stubs(:host).returns(ElectricSheep::Metadata::Host.new(id:'remote'))
        @resource.stubs(:basename).returns('filename.ext')
        @resource.stubs(:path).returns('remote/filename.ext')
        #should create folder
        FileUtils.expects(:mkdir_p).with('$HOME/.electric_sheep/remote')
      end

      it "should copy" do
        should_log_msg(:copy, 'remote','localhost')
        @scp.expects(:download!).with('remote/filename.ext','$HOME/.electric_sheep/remote/filename.ext',{verbose:true})
        @meta_scp.copy
      end

      it "should move" do
        should_log_msg(:move, 'remote', 'localhost')
        @scp.expects(:download!).with('remote/filename.ext','$HOME/.electric_sheep/remote/filename.ext',{verbose:true})
        @meta_scp.expects(:ssh_exec).with(@ssh, "rm -f remote/filename.ext").returns true
        @meta_scp.move
      end
    end

    describe 'local to remote' do
      before do
        @to = ElectricSheep::Metadata::Host.new(id:'remote')
        @meta_scp.stubs(:option).with(:to).returns('remote')
        @hosts.stubs(:get).with('remote').returns(@to)
        @resource.stubs(:host).returns(ElectricSheep::Metadata::Localhost.new)
        @resource.stubs(:basename).returns('filename.ext')
        @resource.stubs(:path).returns('local/filename.ext')
        @shell.stubs(:parse_env_variable).returns("local/filename.ext")
        @meta_scp.expects(:ssh_exec).with(@ssh,'echo $HOME/.electric_sheep/remote/filename.ext').returns({out:"/remote/home/filename.ext"})
        #should create folder
        @meta_scp.expects(:ssh_exec).with(@ssh, "mkdir -p $HOME/.electric_sheep/remote")
      end

      it "should copy" do
        should_log_msg(:copy, 'localhost', 'remote')
        @scp.expects(:upload!).with('local/filename.ext','/remote/home/filename.ext',{verbose:true})
        @meta_scp.copy
      end

      it "should move" do
        should_log_msg(:move, 'localhost', 'remote')
        @scp.expects(:upload!).with('local/filename.ext','/remote/home/filename.ext',{verbose:true})
        FileUtils.expects(:rm_f).with('local/filename.ext')
        @meta_scp.move
      end
    end

    def should_log_msg(type, from, to)
      @logger.expects(:info).
        with("Will #{type} filename.ext from #{from} to #{to} using SCP")
    end
end
