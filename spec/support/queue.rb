module Support
    module Queue
        extend ActiveSupport::Concern

        included do
            describe 'queuing' do
                before do
                    @queue = subject.new
                    @items = queue_items
                    @items.each do |item|
                        @queue.add item
                    end
                end

                it 'provides queue size' do
                    @queue.size.must_equal @items.size
                    @queue.remaining.must_equal @items.size
                end

                it 'retains steps order' do
                    @items.size.times do |i|
                        @queue.next!.must_equal @items[i]
                        @queue.remaining.must_equal @items.size - ( i + 1 )
                        @queue.size.must_equal @items.size
                    end
                end

            end
        end
    end
end
