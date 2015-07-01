require 'spec_helper'

describe ElectricSheep::Metadata::Options do
  OptionsKlazz = Class.new do
    include ElectricSheep::Metadata::Options

    def initialize(opts = {})
      @options = opts
    end

    option :option1
    option :option2, default: 'default_value'
  end

  describe OptionsKlazz do
    it 'does not return an undeclared option' do
      subject.new(option3: 'value').option(:option3).must_be_nil
    end

    it 'returns a declared option' do
      subject.new(option1: 'value', option2: 'value').tap do |options|
        [:option1, :option2].each do |opt|
          options.option(opt).must_equal 'value'
        end
      end
    end

    it 'uses an option default value' do
      subject.new.option(:option2).must_equal 'default_value'
    end

    it 'indicates whether an option exists' do
      subject.new.tap do |options|
        options.option?(:option1).must_equal true
        options.option?(:option3).must_equal false
      end
    end
  end
end
