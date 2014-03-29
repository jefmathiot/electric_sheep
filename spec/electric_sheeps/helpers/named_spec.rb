require 'spec_helper'
require 'timecop'

describe ElectricSheeps::Helpers::Named do

  NamedKlazz = Class.new do
    include ElectricSheeps::Helpers::Named
  end

  describe 'creating directory names' do

    before do
      @named = NamedKlazz.new
    end

    it 'creates a simple name' do
      @named.with_named_dir('/tmp', 'dir').must_equal '/tmp/dir'
    end

    it 'escapes the name' do
      @named.with_named_dir('/tmp', "\"dir").must_equal "/tmp/\\\"dir"
    end

    it 'appends a timestamp' do
      Timecop.travel(Time.utc(2014, 1, 2, 3, 2, 1)) do
        @named.with_named_dir('/tmp', 'dir', timestamp: true).must_equal '/tmp/dir-20140102-030201'
      end
    end

    it 'yields the provided block' do
      yielded = nil
      result = @named.with_named_dir '/tmp', 'dir' do |dir|
        yielded = dir
        "some-arbitrary-expression"
      end
      result.must_equal '/tmp/dir'
      yielded.must_equal result
    end

  end

end
