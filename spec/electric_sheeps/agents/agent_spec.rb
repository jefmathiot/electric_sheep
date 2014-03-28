require 'spec_helper'

describe ElectricSheeps::Agents::Agent do

  AgentKlazz = Class.new do
    include ElectricSheeps::Agents::Agent
  end

  class FreshAir
    include ElectricSheeps::Resources::Resource
  end

  describe AgentKlazz do

    it 'registers' do
      ElectricSheeps::Agents::Register.expects(:register).with(subject, {as: 'test', of_type: :command})
      subject.register as: 'test', of_type: :command
    end

    it 'declares a file resource by default' do
      subject.resource :some_resource
      subject.resources[:some_resource].must_equal ElectricSheeps::Resources::File
    end

    it 'overrides the resource type' do
      subject.resource :some_resource, kind_of: FreshAir
      subject.resources[:some_resource].must_equal FreshAir
    end

  end
end
