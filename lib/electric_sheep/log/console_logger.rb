require 'logger'

module ElectricSheep
  module Log
    class ConsoleLogger
      def initialize(out, err=nil)
        @out = out
        @err = err || @out
      end

      [:info, :debug, :warn].each do |log|
        define_method log do |*args|
          @out.puts *args
        end
      end

      [:error, :fatal].each do |log|
        define_method log do |*args|
          @err.puts *args
        end
      end
    end
  end
end
