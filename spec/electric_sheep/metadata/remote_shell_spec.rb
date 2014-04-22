require 'spec_helper'

describe ElectricSheep::Metadata::RemoteShell do
  include Support::ShellMetadata
  include Support::Properties
  include Support::Hosts

  it{
    defines_properties :host, :user
    requires :host, :user
  }

  describe 'validating host' do
    it 'does not validate if host is unknown' do
      expects_validation_error(subject.new(host: 'test'), :host,
        /Unknown host with id test/)
    end

    it 'validates' do
      config = ElectricSheep::Config.new
      config.hosts.add('test', hostname: 'some.host.tld')
      subject.new(host: 'test', user: 'operator').validate(config).must_equal true
    end
  end
end
