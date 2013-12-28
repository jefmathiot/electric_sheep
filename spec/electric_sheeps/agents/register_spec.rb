require 'spec_helper'

describe ElectricSheeps::Agents::Register do

    it 'should allow command registration' do
        subject.register Object, as: "fake", of_type: :command
        subject.command("fake").must_equal Object
    end

end
