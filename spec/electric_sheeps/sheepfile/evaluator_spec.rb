require 'spec_helper'

describe ElectricSheeps::Sheepfile::Evaluator do

  before do
    @path = File.expand_path('Sheepfile')
  end

  it 'raises if configuration file does not exist' do
    File.expects(:exists?).with( @path ).returns false
    -> { subject.new('Sheepfile').evaluate }.must_raise RuntimeError
  end

  it 'evaluates file contents in DSL' do
        # TODO Find a way to test this without actually hitting the DSL
        File.expects(:exists?).with( @path ).returns true
        File.expects(:open).with( @path, 'rb').returns mock(read: <<-EOS
          host "some-host" do
            description "Some host description"
            name "some-host.tld"
          end
          EOS
          )
        config = subject.new('Sheepfile').evaluate
        config.hosts.get('some-host').name.must_equal 'some-host.tld'
      end
    end
