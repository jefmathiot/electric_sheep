require 'spec_helper'

describe ElectricSheeps::Metadata::RemoteShell do
  include Support::ShellMetadata
  include Support::Hosts

  before do
    @host = new_host
    @user = 'op'
  end

  it 'binds to an host' do
    metadata = subject_instance
    metadata.host.must_equal @host
  end

  it 'defines a user' do
    metadata = subject_instance
    metadata.user.must_equal @user
  end

  def subject_instance
    subject.new(host: @host, user: @user)
  end
end
