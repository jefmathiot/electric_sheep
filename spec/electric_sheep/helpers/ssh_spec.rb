require 'spec_helper'

describe ElectricSheep::Helpers::SSH do
  SSHKlazz = Class.new do
    include ElectricSheep::Helpers::SSH

    attr_reader :connection, :provided_host, :provided_user, :provided_pk

    def initialize
      @project=ElectricSheep::Metadata::Project.new
      @project.use_private_key! '~/pk'
      @connection=Object.new
    end

    def option(opt)
      return 'user' if opt==:as
    end

    def ssh_session(host, user, private_key, &block)
      block.call @connection
      @provided_host=host
      @provided_user=user
      @provided_pk=private_key
    end
  end

  describe SSHKlazz do
    it 'wraps block execution in remote session' do
      connection=nil
      ssh=subject.new
      ssh.in_remote_session(host=mock) do |conn|
        connection=conn
      end
      connection.must_equal ssh.connection
      ssh.provided_host.must_equal host
      ssh.provided_user.must_equal 'user'
      ssh.provided_pk.must_equal '~/pk'
   end
  end
end
