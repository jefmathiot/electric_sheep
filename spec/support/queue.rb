module Support
  module Queue
    extend ActiveSupport::Concern

    included do
      describe 'queuing' do
        before do
          if subject.ancestors.include?(ElectricSheep::Metadata::Configured)
            @queue = subject.new(mock)
          else
            @queue = subject.new
          end
          @items = queue_items
          @items.each do |item|
            @queue.add item
          end
        end

        it 'gives its size' do
          @queue.size.must_equal @items.size
        end

        it 'iterates through items' do
          times = 0
          @queue.iterate do |item|
            @items[times].must_equal item
            times += 1
          end
          times.must_equal @items.size
        end
      end
    end
  end
end
