require 'spec_helper'

describe ElectricSheep::Resources::Resource do
  ResourceKlazz = Class.new do
    include ElectricSheep::Resources::Resource
  end

  describe ResourceKlazz do
    it 'initializes with a name option' do
      subject.new(name: "some-name").name.must_equal "some-name"
    end
  end
end
