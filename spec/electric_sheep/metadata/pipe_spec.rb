require 'spec_helper'

describe ElectricSheep::Metadata::Pipe do

  PipeKlazz=Class.new do
    include ElectricSheep::Metadata::Pipe
  end

  describe PipeKlazz do
    [:item1, :item2, :resource, :start_location].each do |m|
      let(m){mock}
    end

    let(:pipe){ subject.new }

    describe 'pipelining' do

      before do
        resource.expects(:to_location).returns(start_location)
      end

      it 'stores its input and start location' do
        pipe.pipelined(resource)
        pipe.input.must_equal resource
        pipe.start_location.must_equal start_location
      end

      describe 'iterating through its queue' do

        let(:products){ [] }
        let(:resources){ [] }

        before do
          [item1, item2].each do |item|
            pipe.add item
          end
          time=0
          pipe.pipelined(resource) do |item, resource|
            products << mock
            resources << resource
            item.stubs(:execution_time).returns(time+=1)
            products.last
          end
        end

        it 'retains the original input and start location' do
          pipe.input.must_equal resource
          pipe.start_location.must_equal start_location
        end

        it 'creates an exec trail for each step' do
          pipe.execs.size.must_equal 2
        end

        it 'yields the previous product to each block' do
          resources.must_equal [resource, products.first]
        end

        it 'keeps metadata, product and execution time of each step' do
          pipe.execs.first.tap do |trail|
            trail.metadata.must_equal item1
            trail.product.must_equal products.first
            trail.execution_time.must_equal 1
          end
        end

        it 'returns the last product' do
          pipe.last_product.must_equal products.last
        end

      end

    end

  end

end
