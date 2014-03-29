require 'spec_helper'

describe ElectricSheeps::Resources::File do

  it 'has a filename attribute' do
    subject.new(filename: 'myfile.txt').filename.must_equal 'myfile.txt'
  end
end
