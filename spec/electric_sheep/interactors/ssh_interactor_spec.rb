# encoding: utf-8

require 'spec_helper'
require 'net/ssh/test'

describe ElectricSheep::Interactors::SshInteractor do
  include Net::SSH::Test

  module Net
    module SSH
      module Test
        # Avoid Net::SSH::Test::Extensions to collide with Coveralls
        class << self
          def remove_io_aliases
            ::IO.class_eval <<-EOF
                class << self
                  alias_method :select, :select_for_real
                end
              EOF
          end

          def create_io_aliases
            ::IO.class_eval <<-EOF
              class << self
                  alias_method :select_for_real, :select
                  alias_method :select, :select_for_test
                end
              EOF
          end
        end

        remove_io_aliases

        class Kex
          def exchange_keys
            result = Net::SSH::Buffer.from(:byte, NEWKEYS)
            @connection.send_message(result)

            buffer = @connection.next_message
            unless buffer.type == NEWKEYS
              fail Net::SSH::Exception, 'expected NEWKEYS'
            end

            {
              session_id: 'abc-xyz',
              # :server_key        => OpenSSL::PKey::RSA.new(512),
              shared_secret: OpenSSL::BN.new('1234567890', 10),
              hashing_algorithm: OpenSSL::Digest::SHA1
            }
          end
        end
      end
    end
  end

  before do
    Net::SSH::Test.create_io_aliases
  end

  let(:logger) { mock }
  let(:ssh_options) { ElectricSheep::Metadata::SshOptions.new }
  let(:interactor) do
    subject.new(host, job, 'johndoe', ssh_options, logger)
  end

  let(:host) do
    ElectricSheep::Metadata::Host.new(hostname: 'host.tld')
  end

  let(:job) do
    mock.tap do |job|
      job.stubs(:id).returns('my-job')
    end
  end

  after do
    Net::SSH::Test.remove_io_aliases
  end

  describe 'selecting the private key' do
    let(:host) { mock }
    let(:job) { mock }

    it 'uses the host key if specified' do
      host.expects(:private_key).returns('key_rsa')
      interactor.send(:private_key)
        .must_equal File.expand_path('key_rsa')
    end

    it 'falls back to the job key' do
      host.expects(:private_key).returns(nil)
      job.expects(:private_key).returns('key_rsa')
      interactor.send(:private_key)
        .must_equal File.expand_path('key_rsa')
    end

    it 'falls back to the default key' do
      host.expects(:private_key).returns(nil)
      job.expects(:private_key).returns(nil)
      interactor.send(:private_key)
        .must_equal File.expand_path('~/.ssh/id_rsa')
    end
  end

  describe 'with a session' do
    def build_ssh_story(cmd, replies = {}, exit_status = 0)
      story do |session|
        channel = session.opens_channel
        channel.sends_exec cmd
        replies.each do |type, reply|
          channel.send "gets_#{type}", reply
        end
        yield if block_given?
        channel.gets_exit_status(exit_status)
        channel.gets_close
        channel.sends_close
      end
    end

    let :default_options do
      { port: 22, keys_only: true, auth_methods: ['publickey'],
        key_data: 'SECRET',
        user_known_hosts_file: File.expand_path('~/.ssh/known_hosts'),
        paranoid: :very }
    end

    def self.expecting_ssh_session
      before do
        ElectricSheep::Interactors::SshInteractor::PrivateKey.expects(:get_key)
          .with('/path/to/private/key', :private)
          .returns(pk = mock)
        pk.expects(:export).returns('SECRET')
        Net::SSH.expects(:start)
          .with('host.tld', 'johndoe', options)
          .returns(connection)
        job.expects(:private_key).returns('/path/to/private/key')
        ElectricSheep::Helpers::Directories.any_instance
          .expects(:mk_job_directory!)
      end
    end

    describe 'with specific SSH options' do
      let :options do
        default_options.merge(paranoid: :secure,
                              user_known_hosts_file: '/path/to/known_hosts')
      end

      let(:ssh_options) do
        ElectricSheep::Metadata::SshOptions
          .new(known_hosts: '/path/to/known_hosts', host_key_checking: 'strict')
      end

      expecting_ssh_session

      it 'starts the session using the specific options' do
        interactor.in_session
      end
    end

    describe 'with default SSH options' do
      let :options do
        default_options
      end

      expecting_ssh_session

      it 'logs to stderr on failing exec' do
        story do |session|
          channel = session.opens_channel
          channel.sends_exec 'whatever', true, false
          channel.gets_close
          channel.sends_close
        end
        logger.expects(:debug).with('whatever')
        assert_scripted do
          interactor.in_session do
            proc { interactor.exec 'whatever' }.must_raise RuntimeError
          end
        end
      end

      it 'should return stdout output' do
        build_ssh_story 'echo "Hello World"', data: 'Hello World'
        logger.expects(:debug).with('echo "Hello World"')
        logger.expects(:debug).with('Hello World')
        assert_scripted do
          interactor.in_session do
            result = interactor.exec 'echo "Hello World"'
            result.must_equal(out: 'Hello World', err: '', exit_status: 0)
          end
        end
      end

      it 'should return stderr output' do
        build_ssh_story 'echo "Goodbye Cruel World" >&2',
                        extended_data: 'Goodbye Cruel World'
        logger.expects(:debug).with('echo "Goodbye Cruel World" >&2')
        assert_scripted do
          interactor.in_session do
            result = interactor.exec 'echo "Goodbye Cruel World" >&2'
            result.must_equal(out: '', err: 'Goodbye Cruel World',
                              exit_status: 0)
          end
        end
      end

      it 'should return both stdout and stderr' do
        build_ssh_story 'echo "Hello World" ; echo "Goodbye Cruel World" >&2',
                        data: 'Hello World',
                        extended_data: 'Goodbye Cruel World'
        logger.expects(:debug)
          .with('echo "Hello World" ; echo "Goodbye Cruel World" >&2')
        logger.expects(:debug).with('Hello World')
        assert_scripted do
          interactor.in_session do
            result = interactor.exec('echo "Hello World" ; ' \
              'echo "Goodbye Cruel World" >&2')
            result.must_equal(out: 'Hello World', err: 'Goodbye Cruel World',
                              exit_status: 0)
          end
        end
      end

      describe 'on returning status' do
        it 'should succeed' do
          build_ssh_story 'echo "Hello World"', data: 'Hello World'
          logger.expects(:debug).with('echo "Hello World"')
          logger.expects(:debug).with('Hello World')
          assert_scripted do
            result = nil
            interactor.in_session do
              result = interactor.exec('echo "Hello World"')
            end
            result[:exit_status].must_equal 0
            result[:out].must_equal 'Hello World'
          end
        end

        it 'should fail gracefully' do
          build_ssh_story 'ls --wtf', { extended_data: 'An error' }, 2
          logger.expects(:debug).with('ls --wtf')
          assert_scripted do
            interactor.in_session do
              proc { interactor.exec('ls --wtf') }.must_raise RuntimeError
            end
          end
        end

        it 'should be able to delete resources' do
          resource = mock(path: 'resource')
          cmd = 'rm -rf /path/to/resource'
          build_ssh_story cmd, {}
          logger.expects(:debug).with(cmd)
          interactor.expects(:expand_path).with('resource')
            .returns('/path/to/resource')
          assert_scripted do
            interactor.in_session do
              result = interactor.delete!(resource)
              result[:exit_status].must_equal 0
            end
          end
        end
      end
    end
  end

  it 'uses the SCP from SSH session' do
    interactor.expects(:session).returns(mock(scp: scp = mock))
    interactor.scp.must_equal scp
  end

  describe 'transfering resources' do
    [:input, :output].each do |m|
      let(m) do
        mock.tap do |r|
          r.stubs(:path).returns(m.to_s)
        end
      end

      let("#{m}_path") { "/path/to/#{m}" }
    end

    let(:local_interactor) { mock }

    let(:scp) { mock }

    let(:seq) { sequence('transfer') }

    before do
      interactor.stubs(:scp).returns(scp)
    end

    def expects_paths_expansion(input_expander, output_expander)
      input_expander.expects(:expand_path).with(input.path)
        .returns(input_path)
      output_expander.expects(:expand_path).with(output.path)
        .returns(output_path)
    end

    def expects_file_op(action, _interactor)
      scp.expects(action).in_sequence(seq)
        .with(input_path, output_path, recursive: input.directory?)
    end

    def expects_directory_op(action, interactor)
      path_regexp = %r{\/path\/to\/tmp\d{8}}
      interactor.expects(:exec).in_sequence(seq)
        .with(regexp_matches(/^mkdir #{path_regexp}/))
      scp.expects(action).in_sequence(seq)
        .with(input_path, regexp_matches(path_regexp),
              recursive: input.directory?)
      interactor.expects(:exec).in_sequence(seq)
        .with(regexp_matches(/^mv #{path_regexp}.* #{output_path}/))
      interactor.expects(:exec).in_sequence(seq)
        .with(regexp_matches(/^rm -rf #{path_regexp}/))
    end

    def self.ensure_scp(type, action)
      it "#{action}s a #{type}" do
        [:input, :output].each do |m|
          send(m).stubs(:directory?).returns(type == :directory)
        end
        expanders = [local_interactor, interactor]
        expanders.reverse! if action == :download
        expects_paths_expansion(*expanders)
        send "expects_#{type}_op", "#{action}!", expanders.last
        interactor.send "#{action}!", input, output, local_interactor
      end
    end

    ensure_scp :file, :download
    ensure_scp :file, :upload
    ensure_scp :directory, :download
    ensure_scp :directory, :upload
  end
end

describe ElectricSheep::Interactors::SshInteractor::PrivateKey do
  describe 'getting a key from the file system' do
    def create_keyfile(name, contents)
      Tempfile.new(name).tap do |f|
        f.write contents
        f.close
      end
    end

    let(:ssh_keyfile) { create_keyfile('ssh-key', 'ssh-rsa XXXXXXX') }
    let(:pem_keyfile) { create_keyfile('ssh-key', pem_lines) }
    let(:not_a_keyfile) { create_keyfile('not-a-key', '¯\_(ツ)_/¯') }

    let(:pem_lines) do
      "-----BEGIN RSA PUBLIC KEY-----\n" \
      "XXXXXX\n" \
      '-----END RSA PUBLIC KEY-----'
    end

    let(:spawn) do
      ElectricSheep::Spawn
    end

    def expects_open_ssl(check)
      OpenSSL::PKey::RSA.expects(:new).with(pem_lines).returns(key = mock)
      key.expects(check).returns(true)
      key
    end

    it 'raises if the key is of the wrong type' do
      subject.expects(:read_keyfile).with(path = '/path/to/key')
        .returns(keyfile = mock)
      OpenSSL::PKey::RSA.expects(:new).with(keyfile).returns(key = mock)
      key.expects(:private?).returns(false)
      ex = -> { subject.get_key(path, :private) }.must_raise RuntimeError
      ex.message.must_match(/^Not a private key/)
    end

    it 'raises if keyfile is not found' do
      ex = -> { subject.get_key('not/a/key', :private) }.must_raise RuntimeError
      ex.message.must_match(/^Key file not found/)
    end

    describe 'with an SSH key' do
      def expects_conversion(status)
        spawn.expects(:exec)
          .with("ssh-keygen -f #{ssh_keyfile.path} -e -m pem")
          .returns(out: pem_lines, err: 'An error', exit_status: status)
      end

      it 'converts the key to the PEM format' do
        expects_conversion(0)
        key = expects_open_ssl(:public?)
        subject.get_key(ssh_keyfile.path, :public).must_equal key
      end

      it 'raises if it was unable to convert to PEM' do
        expects_conversion(1)
        ex = lambda do
          subject.get_key(ssh_keyfile.path, :private)
        end.must_raise RuntimeError
        ex.message.must_match(/Unable to convert key file/)
      end
    end

    it 'uses a key in the PEM format without converting it' do
      key = expects_open_ssl(:public?)
      subject.get_key(pem_keyfile.path, :public).must_equal key
    end

    it 'raises if the key format is unknown' do
      ex = lambda do
        subject.get_key(not_a_keyfile, :whatever)
      end.must_raise RuntimeError
      ex.message.must_match(/Key file format not supported/)
    end
  end
end
