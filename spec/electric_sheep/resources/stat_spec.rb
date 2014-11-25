require 'spec_helper'

describe ElectricSheep::Resources::Stat do

  it 'humanizes size' do
    subject.new.tap{|stat| stat.size=4096 }.humanize.must_equal '4 KB'
  end

  it 'handles nil size' do
    subject.new.humanize.must_equal 'Unknown'
  end

end