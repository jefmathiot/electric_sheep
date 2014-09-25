require 'spec_helper'
require 'net/ssh/test'

describe ElectricSheep::Shell::RemoteShell do
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
    @logger = mock
  end

  after do
    Net::SSH::Test.remove_io_aliases
  end

  it 'indicates its type' do
    subject.new(nil, nil, nil, nil).tap do |shell|
      shell.remote?.must_equal true
      shell.local?.must_equal false
    end
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

    before do
      ElectricSheep::Crypto.expects(:get_key).
        with('/path/to/private/key', :private).
        returns(pk = mock)
      pk.expects(:export).returns('SECRET')
      Net::SSH.expects(:start).
        with('localhost', 'johndoe', port: 22, key_data: 'SECRET', keys_only: true).
        returns( connection )
      user = 'johndoe'
      @logger.expects(:info).
        with("Starting a remote shell session for johndoe@localhost on port 22")
      host = ElectricSheep::Metadata::Host.new(hostname: 'localhost')
      @shell = subject.new( @logger, host, 'johndoe', @project=mock )
      @project.expects(:private_key).returns('/path/to/private/key')
      @shell.open!
    end

    it "should have open the session" do
      @shell.opened?.must_equal true
    end

    it 'should log to stderr on failing exec' do
      story do |session|
        channel = session.opens_channel
        channel.sends_exec 'whatever', true, false
        channel.gets_close
        channel.sends_close
      end
      @logger.expects(:error, "Could not execute command whatever")
      assert_scripted do
        @shell.exec 'whatever'
      end
    end

    it 'should output stdout to logger' do
      build_ssh_story 'echo "Hello World"', {data: 'Hello World'}
      @logger.expects(:info).with('Hello World')
      @logger.expects(:error).never
      assert_scripted do
        @shell.exec 'echo "Hello World"'
      end
    end

    it 'should output stderr to logger' do
      build_ssh_story 'echo "Goodbye Cruel World" >&2', {extended_data: 'Goodbye Cruel World'}
      @logger.expects(:error).with('Goodbye Cruel World')
      @logger.expects(:info).never
      assert_scripted do
        @shell.exec 'echo "Goodbye Cruel World" >&2'
      end
    end

    it 'should output both stdout and stderr to logger' do
      build_ssh_story 'echo "Hello World" ; echo "Goodbye Cruel World" >&2',
      {data: 'Hello World', extended_data: 'Goodbye Cruel World'}
      @logger.expects(:info).with('Hello World')
      @logger.expects(:error).with('Goodbye Cruel World')
      assert_scripted do
        @shell.exec 'echo "Hello World" ; echo "Goodbye Cruel World" >&2'
      end
    end

    it 'should close' do
      @shell.instance_variable_get(:@interactor).session.expects(:close)
      @shell.close!.opened?.must_equal false
    end

    describe 'on returning status' do
      it 'should succeed' do
        build_ssh_story 'echo "Hello World"', {data: 'Hello World'}
        @logger.expects(:info).with('Hello World')
        @logger.expects(:error).never
        assert_scripted do
          result = @shell.exec('echo "Hello World"')
          result[:exit_status].must_equal 0
          result[:out].must_equal 'Hello World'
        end
      end

      it 'should fail gracefully' do
        build_ssh_story 'ls --wtf', {extended_data: 'An error'}, 2
        @logger.expects(:info).never
        @logger.expects(:error).with('An error')
        assert_scripted do
          result = @shell.exec('ls --wtf')
            result[:exit_status].must_equal 2
            result[:err].must_equal 'An error'
        end
      end
    end

  end
end
