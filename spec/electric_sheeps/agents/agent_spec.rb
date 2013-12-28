require 'spec_helper'

describe 'ElectricSheeps::Agents::Agent' do

    Klazz = Class.new do
        include ElectricSheeps::Agents::Agent
    end

    describe Klazz do

        it 'should allow registration of classes' do
            ElectricSheeps::Agents::Register.expects(:register).with(subject, {as: 'test', of_type: :command})
            subject.register as: 'test', of_type: :command
        end

    end
end
