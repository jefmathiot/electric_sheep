module ElectricSheep
  module Metadata
    module Options
      extend ActiveSupport::Concern

      included do
        alias_method :initialize_without_options, :initialize

        def initialize(args = {})
          self.class.init_options.each do |option|
            self.class.send :attr_accessor, option
            instance_variable_set "@#{option}", args.is_a?(String) ? args : args[option]
          end
          initialize_without_options
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
