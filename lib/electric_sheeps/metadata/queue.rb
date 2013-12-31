module ElectricSheeps
    module Metadata
        module Queue

            def add(item)
                @items << item
                item
            end

            def size
                @items.size
            end

            def remaining
                [@items.size - @current, 0].max
            end

            def next!
                @current += 1
                @items[@current - 1]
            end

            def reset!
                @items = []
                @current = 0
            end

        end
    end
end
