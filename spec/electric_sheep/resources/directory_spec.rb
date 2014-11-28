require 'spec_helper'

describe ElectricSheep::Resources::Directory do
  include Support::Files::Named

  it 'indicates its type' do
    subject.new.file?.must_equal false
    subject.new.directory?.must_equal true
  end

  it 'lets the world know its type' do
    subject.new.type.must_equal 'directory'
  end
end
