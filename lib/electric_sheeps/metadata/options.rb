module ElectricSheeps
  module Metadata
    module Options
      extend ActiveSupport::Concern

      included do
        alias_method :initialize_without_options, :initialize
        def initialize(*args)
          if args.last.is_a?(Hash)
            options = args.pop
            self.class.init_options.each do |option|
              self.class.send :attr_reader, option
              instance_variable_set "@#{option}", options[option]
            end
          end
          initialize_without_options *args
        end
      end

      module ClassMethods

        attr_reader :init_options

        def optionize(*opts)
          @init_options = opts
        end
      end
    end
  end
end
