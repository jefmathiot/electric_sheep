require 'spec_helper'

describe ElectricSheeps::Resources::Resource do
  ResourceKlazz = Class.new do
    include ElectricSheeps::Resources::Resource
  end

  describe ResourceKlazz do
    it 'initializes with a name option' do
      subject.new(name: "some-name").name.must_equal "some-name"
    end
  end
end
