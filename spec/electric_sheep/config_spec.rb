require 'spec_helper'

describe ElectricSheep::Config do
  include Support::Queue

  def queue_items
    ([0] * 2).map do
      ElectricSheep::Metadata::Job.new
    end
  end

  before do
    @config = subject.new
  end

  it 'initializes an empty hosts' do
    @config.hosts.must_be_instance_of ElectricSheep::Metadata::Hosts
  end

  it 'initializes an empty set of ssh options' do
    @config.ssh_options.must_be_instance_of ElectricSheep::Metadata::SshOptions
  end
end
