require 'spec_helper'

describe ElectricSheep::Sheepfile::Evaluator do

  before do
    @path = File.expand_path('Sheepfile')
  end

  it 'raises if configuration file does not exist' do
    File.expects(:exists?).with( @path ).returns false
    -> { subject.new('Sheepfile').evaluate }.must_raise RuntimeError
  end

  it 'raises if configuration file is not readable' do
    File.expects(:exists?).with( @path ).returns true
    File.expects(:readable?).with( @path ).returns false
    -> { subject.new('Sheepfile').evaluate }.must_raise RuntimeError
  end

  it 'evaluates file contents in DSL' do
    File.expects(:exists?).with( @path ).returns true
    File.expects(:readable?).with( @path ).returns true
    File.expects(:open).with( @path, 'rb').returns mock(read: <<-EOS
      host "some-host", hostname: "some-host.tld"
      EOS
    )
    config = subject.new('Sheepfile').evaluate
    config.hosts.get('some-host').hostname.must_equal 'some-host.tld'
  end

  it 'evaluates file contents in DSL with syntax error' do
    File.expects(:exists?).with( @path ).returns true
    File.expects(:readable?).with( @path ).returns true
    File.expects(:open).with( @path, 'rb').returns mock(read: <<-EOS
      host "some-host", hostname: "some-host.tld
      host "some-host-2",, hostname: "some-host.tld"
      EOS
    )

    err = ->{ config = subject.new('Sheepfile').evaluate}.must_raise ElectricSheep::SheepException
    err.message.must_match /Syntax error in .*Sheepfile line: 2/
  end

end
