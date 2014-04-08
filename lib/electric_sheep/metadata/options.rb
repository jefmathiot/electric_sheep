module ElectricSheep
  module Metadata
    module Options
      extend ActiveSupport::Concern

      included do
        alias_method :initialize_without_options, :initialize

        def initialize(args = {})
          check_parameters(args)

          raise "One value had been passed but #{self.class.init_options.size} is required" if (self.class.init_options.size > 1) && (args.is_a? (String))

          self.class.init_options.each do |option|
            self.class.send :attr_accessor, option
            instance_variable_set "@#{option}", args.is_a?(String) ? args : args[option]
          end
          initialize_without_options
        end

        private
        def check_parameters(args)
          case args
            when NilClass
              raise Exception.new("No options")
            when String.class
              raise Exception.new("One option is given but more than one option is expected #{self.class.init_options} #{args.inspect}") unless self.class.init_options.size == 1
            when Hash.class
              raise Exception.new("Incorrect unknown options #{args.keys - self.class.init_options} on #{self.class}") unless (args.keys - self.class.init_options).empty?
            else
          end
        end
      end

      module ClassMethods
        attr_reader :init_options

        def options(*opts)
          @init_options = opts
        end
      end
    end
  end
end
