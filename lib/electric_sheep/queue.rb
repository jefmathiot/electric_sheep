module ElectricSheep
  module Queue
    delegate :size, to: :queue

    def add(item)
      queue << item
      item
    end

    def iterate
      queue.each do |item|
        yield item if block_given?
      end
    end

    def queue
      @queue ||= []
    end
  end
end
