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

  it 'normalizes its path' do
    subject.new(path: 'path/to/file.ext1.ext2').tap do |resource|
      resource.extension.must_equal '.ext1.ext2'
      resource.basename.must_equal 'file'
      resource.parent.must_equal 'path/to'
    end
  end

end
