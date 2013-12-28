require 'spec_helper'

describe ElectricSheeps::Metadata::Project do

    it "should initialize the project's description" do
        subject.new(description: 'A description').description.must_equal 'A description'
    end

    it 'should add shells' do
        
    end

    it 'should add transports' do

    end
end
