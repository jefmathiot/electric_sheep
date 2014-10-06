require 'spec_helper'

describe ElectricSheep::Resources::Directory do
  include Support::Files::Named

  it 'indicates its type' do
    subject.new.file?.must_equal false
    subject.new.directory?.must_equal true
  end
end
