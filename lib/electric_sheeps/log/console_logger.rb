require 'logger'

module ElectricSheeps
    module Log
        class ConsoleLogger
            def initialize(out, err=nil)
                @out = out
                @err = err || @out
            end

            [:info, :debug, :warn].each do |log|
                define_method log do |*args|
                    @out.send(log, *args)
                end
            end

            [:error, :fatal].each do |log|
                define_method log do |*args|
                    @err.send(log, *args)
                end
            end
        end
    end
end