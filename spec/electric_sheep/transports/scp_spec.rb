require 'spec_helper'
require 'net/ssh/test'

describe ElectricSheep::Transports::SCP do

  let :localhost do
    ElectricSheep::Metadata::Localhost.new
  end

  let :remote_host do
    ElectricSheep::Metadata::Host.new
  end

  [:file, :directory].each do |type|
    let "remote_#{type}" do
      ElectricSheep::Resources.const_get(type.capitalize).new(
        host: remote_host, path: "local/path"
      )
    end

    let "local_#{type}" do
      ElectricSheep::Resources::const_get(type.capitalize).new(
        host: localhost, path: "remote/path"
      )
    end
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

    it 'delegates "copy"' do
      transport.expects(:operate).with(:copy)
      transport.copy
    end

    it 'delegates "move"' do
      transport.expects(:operate).with(:move)
      transport.move
    end

    it 'retrieves the local interactor' do
      transport.send(:interactor_for, hosts.localhost).
        must_equal transport.send(:local_interactor)
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
        transport.stubs(:input).returns(local_file)
      end

      # TODO We should verify the output resources
      it 'tries to visit available operations and log info' do
        retrieve_hosts
        retrieve_interactors
        [
          ElectricSheep::Transports::SCP::DownloadOperation,
          ElectricSheep::Transports::SCP::UploadOperation
        ].each do |klazz|
          instance = klazz.any_instance
          instance.expects(:perform).with(false)
        end
        transport.expects(:log).with(:copy)
        transport.send(:operate, :copy)
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

    describe "executing operations" do

      let :local_interactor do
        mock.tap do |interactor|
          interactor.stubs(:scp).returns(scp)
          interactor.stubs(:expand_path).with(local_file.path).
            returns("/local/path")
        end
      end

      let :remote_interactor do
        mock.tap do |interactor|
          interactor.stubs(:scp).returns(scp)
          interactor.stubs(:expand_path).with(remote_file.path).
            returns("/remote/path")
        end
      end

      let :scp do
        mock
      end

      let :script do
        sequence(:script)
      end

      def self.ensure_laziness(from, to)
        # TODO it should raise an exception...
        it 'does nothing with inconsistent resources (#{from}/#{to})' do
          subject.new(
            from: operation_opts.new(send(from), local_interactor),
            to: operation_opts.new(send(to), remote_interactor)
          ).perform(true).must_equal nil
        end
      end

      def self.spec_comment(delete_source)
        delete_source ?
          "removes the original resource" :
          "lets the original resource unchanged"
      end

      def expects_directory_wrapper(env, &block)
        tmp_regex=/\/#{env}\/tmp\d{8}-/
        interactor=send("#{env}_interactor")
        interactor.expects(:exec).in_sequence(script).
            with(regexp_matches(/^mkdir #{tmp_regex}/))
        yield tmp_regex
        interactor.expects(:exec).in_sequence(script).
          with(regexp_matches(/^mv #{tmp_regex}.* \/#{env}\/path/))
        interactor.expects(:exec).in_sequence(script).
          with(regexp_matches(/^rm -rf #{tmp_regex}.*/))
      end

      describe ElectricSheep::Transports::SCP::UploadOperation do
        ensure_laziness :local_file, :local_file
        ensure_laziness :remote_file, :remote_file

        def self.ensure_upload(delete_source, expected_host, expected_path)

          let :expected_host do
            expected_host=send(expected_hostname)
          end

          it "uploads the file and #{spec_comment(delete_source)}" do
            result = nil
            remote_interactor.expects(:in_session).in_sequence(script).yields
            scp.expects(:upload!).in_sequence(script).with(
              "/local/path",
              "/remote/path"
            )
            local_interactor.expects(:in_session).in_sequence(script).yields
            if delete_source
              local_interactor.expects(:exec).in_sequence(script).
                with("rm -rf /local/path")
            end
            subject.new(
              from: operation_opts.new(local_file, local_interactor),
              to: operation_opts.new(remote_file, remote_interactor)
            ).perform(delete_source)
          end

          it "uploads the directory and #{spec_comment(delete_source)}" do
            result = nil
            remote_interactor.expects(:in_session).in_sequence(script).yields
            expects_directory_wrapper(:remote) do |target_regex|
              scp.expects(:upload!).in_sequence(script).with(
                "/local/path",
                regexp_matches(target_regex),
                recursive: true
              )
            end
            local_interactor.expects(:in_session).in_sequence(script).yields
            if delete_source
              local_interactor.expects(:exec).in_sequence(script).
                with("rm -rf /local/path")
            end
            subject.new(
              from: operation_opts.new(local_directory, local_interactor),
              to: operation_opts.new(remote_directory, remote_interactor)
            ).perform(delete_source)
          end

        end

        ensure_upload false, :localhost, "/local/path"
        ensure_upload true, :remote_host, "/remote/path"

      end

      describe ElectricSheep::Transports::SCP::DownloadOperation do
        ensure_laziness :remote_file, :remote_file
        ensure_laziness :local_file, :local_file

        def self.ensure_download(delete_source, expected_hostname, expected_path)

          let :expected_host do
            expected_host=send(expected_hostname)
          end

          it "downloads the file and #{spec_comment(delete_source)}" do
            result = nil
            remote_interactor.expects(:in_session).in_sequence(script).yields
            scp.expects(:download!).in_sequence(script).with(
              "/remote/path",
              "/local/path"
            )
            if delete_source
              remote_interactor.expects(:exec).in_sequence(script).
                with("rm -rf /remote/path")
            end
            subject.new(
              from: operation_opts.new(remote_file, remote_interactor),
              to: operation_opts.new(local_file, local_interactor)
            ).perform(delete_source)
          end

          it "downloads the directory and #{spec_comment(delete_source)}" do
            result = nil
            remote_interactor.expects(:in_session).in_sequence(script).yields
            expects_directory_wrapper(:local) do |target_regex|
              scp.expects(:download!).in_sequence(script).with(
                "/remote/path",
                regexp_matches(target_regex),
                recursive: true
              )
            end
            if delete_source
              remote_interactor.expects(:exec).in_sequence(script).
                with("rm -rf /remote/path")
            end
            subject.new(
              from: operation_opts.new(remote_directory, remote_interactor),
              to: operation_opts.new(local_directory, local_interactor)
            ).perform(delete_source)
          end
        end

        ensure_download false, :remote_host, "/remote/path"
        ensure_download true, :localhost, "/local/path"

      end

    end

  end

end
