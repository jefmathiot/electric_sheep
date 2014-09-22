require 'spec_helper'
require 'net/ssh/test'

describe ElectricSheep::Transports::SCP do

    before do
      @logger = mock
      @ssh = $ssh = mock
      @ssh.stubs(:scp).returns(@scp = mock)

      @project = ElectricSheep::Metadata::Project.new(id: "remote")
      @metadata = ElectricSheep::Metadata::Transport.new
      @hosts = mock
      @meta_scp = subject.new(@project, @logger, @metadata, @hosts)
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
        @meta_scp.stubs(:option).with(:to).returns(@to = ElectricSheep::Metadata::Localhost.new)
        @resource.stubs(:host).returns(ElectricSheep::Metadata::Host.new)
        @resource.stubs(:basename).returns('filename.ext')
        @resource.stubs(:path).returns('remote/filename.ext')
        #should create folder
        FileUtils.expects(:mkdir_p).with('$HOME/.electric_sheep/remote')
      end

      it "should copy" do
        should_log_msg(:copy)
        @scp.expects(:download!).with('remote/filename.ext','$HOME/.electric_sheep/remote/filename.ext',{verbose:true})
        @meta_scp.copy
      end

      it "should move" do
        should_log_msg(:move)
        @scp.expects(:download!).with('remote/filename.ext','$HOME/.electric_sheep/remote/filename.ext',{verbose:true})
        @meta_scp.expects(:ssh_exec).with(@ssh, "rm -f remote/filename.ext").returns true
        @meta_scp.move
      end
    end

    describe 'local to remote' do
      before do

        @meta_scp.stubs(:option).with(:to).returns(@to = ElectricSheep::Metadata::Host.new)
        @resource.stubs(:host).returns(ElectricSheep::Metadata::Localhost.new)
        @resource.stubs(:basename).returns('filename.ext')
        @resource.stubs(:path).returns('local/filename.ext')
        #should create folder
        @meta_scp.expects(:ssh_exec).with(@ssh, "mkdir -p $HOME/.electric_sheep/remote")
      end

      it "should copy" do
        should_log_msg(:copy)
        @scp.expects(:upload!).with('local/filename.ext','$HOME/.electric_sheep/remote/filename.ext',{verbose:true})
        @meta_scp.copy
      end

      it "should move" do
        should_log_msg(:move)
        @scp.expects(:upload!).with('local/filename.ext','$HOME/.electric_sheep/remote/filename.ext',{verbose:true})
        FileUtils.expects(:rm_f).with('local/filename.ext')
        @meta_scp.move
      end
    end

    def should_log_msg(type)
      @logger.expects(:info).
        with("Will #{type} filename.ext from #{@resource.host.to_s} to #{@to.to_s}")
    end
end
