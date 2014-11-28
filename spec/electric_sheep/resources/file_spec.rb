require 'spec_helper'

describe ElectricSheep::Resources::File do
  include Support::Files::Named
  include Support::Files::Extended

  it 'indicates its type' do
    subject.new.file?.must_equal true
    subject.new.directory?.must_equal false
  end

  it 'lets the world know its type' do
    subject.new.type.must_equal 'file'
  end
end
