require 'logger'

module ElectricSheep
  module Log
    class ConsoleLogger

      def initialize(out, err=nil, verbose_mode=false)
        @verbose_mode = verbose_mode
        @out = out
        @err = err || @out
      end

      protected

      def visible? visibility
        visibility == :runtime || @verbose_mode
      end

      def self.set(names, output, visibility, prefix='')
        names.each do |name|
          define_method name do |*args|
            if args[0].respond_to? :unshift
              args[0].unshift prefix
            else
              args[0] = prefix + args[0]
            end
            instance_variable_get(:"@#{output}").puts *args if visible? visibility
          end
        end
      end

      set [:info], :out, :runtime
      set [:success], :out, :runtime, "[SUCCESS] ".green
      set [:debug], :out, :debug, "[DEBUG] ".blue
      set [:warn], :out, :runtime, "[WARNING] ".blue
      set [:error,:fatal], :err, :runtime, "[ERROR] ".red

    end
  end
end
