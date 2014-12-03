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

  it 'normalizes its path' do
    subject.new(path: 'path/to/directory.noext').tap do |resource|
      resource.basename.must_equal 'directory.noext'
      resource.parent.must_equal 'path/to'
    end
  end

end
