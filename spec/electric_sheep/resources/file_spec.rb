require 'spec_helper'

describe ElectricSheep::Resources::File do

  it 'is a file system resource' do
    subject.new.respond_to?(:path).must_equal true
    subject.new.respond_to?(:remote).must_equal true
  end

  it 'indicates its type' do
    subject.new.file?.must_equal true
    subject.new.directory?.must_equal false
  end
end
