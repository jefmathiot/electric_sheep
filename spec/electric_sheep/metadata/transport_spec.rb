require 'spec_helper'

describe ElectricSheep::Metadata::Transport do
  include Support::Hosts
  include Support::Options

  it{
    defines_options :type, :transport, :to
    requires :type, :transport, :to
  }

  it 'describes a copy' do
    subject.new(type: :copy).tap do |subject|
      subject.copy?.must_equal true
      subject.move?.must_equal false
    end
  end

  it 'describes a move' do
    subject.new(type: :move).tap do |subject|
      subject.move?.must_equal true
      subject.copy?.must_equal false
    end
  end

end

