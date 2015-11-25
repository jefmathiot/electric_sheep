require 'spec_helper'

describe ElectricSheep::Metadata::Configured do
  class FakeConfigured < ElectricSheep::Metadata::Configured
    option :option1
  end

  it 'assigns config and options' do
    subject = FakeConfigured.new(config = mock, option1: 'value')
    subject.config.must_equal config
    subject.option(:option1).must_equal 'value'
  end
end
