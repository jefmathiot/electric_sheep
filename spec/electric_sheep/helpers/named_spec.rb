require 'spec_helper'
require 'timecop'

describe ElectricSheep::Helpers::Named do

  NamedKlazz = Class.new do
    include ElectricSheep::Helpers::Named
  end

  before do
    @named = NamedKlazz.new
  end

  %w(dir file).each do |type|

    describe "creating #{type} names" do

      it 'creates a simple name' do
        @named.send("with_named_#{type}", '/tmp', type).must_equal "/tmp/#{type}"
      end

      it 'escapes the name' do
        @named.send("with_named_#{type}", '/tmp', "\"#{type}").must_equal "/tmp/\\\"#{type}"
      end

      it 'appends a timestamp' do
        Timecop.travel(Time.utc(2014, 1, 2, 3, 2, 1)) do
          @named.send("with_named_#{type}", '/tmp', type, timestamp: true).must_equal "/tmp/#{type}-20140102-030201"
        end
      end

      it 'yields the provided block' do
        yielded = nil
        result = @named.send("with_named_#{type}", '/tmp', type) do |file|
          yielded = file
          "some-arbitrary-expression"
        end
        result.must_equal "/tmp/#{type}"
        yielded.must_equal result
      end

    end

    it 'appends the extension to file name' do
      @named.with_named_file('/tmp', 'some-file', extension: 'rb').
        must_equal '/tmp/some-file.rb'
    end

    it 'appends both the timestamp and extension to file name' do
      Timecop.travel(Time.utc(2014, 1, 2, 3, 2, 1)) do
        @named.with_named_file('/tmp', 'some-file', timestamp: true, extension: 'rb').
        must_equal '/tmp/some-file-20140102-030201.rb'
      end
    end

  end

end
