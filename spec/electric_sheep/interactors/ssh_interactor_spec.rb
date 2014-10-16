require 'spec_helper'
require 'net/ssh/test'

describe ElectricSheep::Interactors::SshInteractor do
  include Net::SSH::Test

  module Net ; module SSH ; module Test

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
        raise Net::SSH::Exception, "expected NEWKEYS" unless buffer.type == NEWKEYS

        { :session_id        => "abc-xyz",
          # :server_key        => OpenSSL::PKey::RSA.new(512),
          :shared_secret     => OpenSSL::BN.new("1234567890", 10),
          :hashing_algorithm => OpenSSL::Digest::SHA1 }
      end
    end
  end ; end ; end

  before do
    Net::SSH::Test.create_io_aliases
  end

  let(:logger) do
    mock
  end

  after do
    Net::SSH::Test.remove_io_aliases
  end

  describe "with a session" do

    def build_ssh_story(cmd, replies={}, exit_status=0)
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

    let(:host) do
      ElectricSheep::Metadata::Host.new(hostname: 'host.tld')
    end

    let(:project) do
      mock.tap do |project|
        project.stubs(:id).returns('my-project')
      end
    end

    before do
      ElectricSheep::Crypto.expects(:get_key).
        with('/path/to/private/key', :private).
        returns(pk = mock)
      pk.expects(:export).returns('SECRET')
      Net::SSH.expects(:start).
        with('host.tld', 'johndoe', port: 22, key_data: 'SECRET', keys_only: true).
        returns( connection )
      user = 'johndoe'
      @interactor= subject.new( host, project, 'johndoe', logger )
      project.expects(:private_key).returns('/path/to/private/key')
      ElectricSheep::Helpers::Directories.any_instance.expects(:mk_project_directory!)
    end

    it 'logs to stderr on failing exec' do
      story do |session|
        channel = session.opens_channel
        channel.sends_exec 'whatever', true, false
        channel.gets_close
        channel.sends_close
      end
      assert_scripted do
        @interactor.in_session do
          proc{ @interactor.exec 'whatever' }.must_raise RuntimeError
        end
      end
    end

    it 'should return stdout output' do
      build_ssh_story 'echo "Hello World"', {data: 'Hello World'}
      assert_scripted do
        @interactor.in_session do
          result = @interactor.exec 'echo "Hello World"'
          result.must_equal({:out=>"Hello World", :err=>"", :exit_status=>0})
        end
      end
    end

    it 'should return stderr output' do
      build_ssh_story 'echo "Goodbye Cruel World" >&2', {extended_data: 'Goodbye Cruel World'}
      assert_scripted do
        @interactor.in_session do
          result = @interactor.exec 'echo "Goodbye Cruel World" >&2'
          result.must_equal({:out=>"", :err=>"Goodbye Cruel World", :exit_status=>0})
        end
      end
    end

    it 'should return both stdout and stderr' do
      build_ssh_story 'echo "Hello World" ; echo "Goodbye Cruel World" >&2',
      {data: 'Hello World', extended_data: 'Goodbye Cruel World'}
      assert_scripted do
        @interactor.in_session do
          result = @interactor.exec 'echo "Hello World" ; echo "Goodbye Cruel World" >&2'
          result.must_equal({:out=>"Hello World", :err=>"Goodbye Cruel World", :exit_status=>0})
        end
      end
    end

    describe 'on returning status' do
      it 'should succeed' do
        build_ssh_story 'echo "Hello World"', {data: 'Hello World'}
        assert_scripted do
          result=nil
          @interactor.in_session do
            result = @interactor.exec('echo "Hello World"')
          end
          result[:exit_status].must_equal 0
          result[:out].must_equal 'Hello World'
        end
      end

      it 'should fail gracefully' do
        build_ssh_story 'ls --wtf', {extended_data: 'An error'}, 2
        assert_scripted do
          @interactor.in_session do
            proc{ @interactor.exec('ls --wtf') }.must_raise RuntimeError
          end
        end
      end
    end

  end
end
