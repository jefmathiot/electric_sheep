module ElectricSheep
  module Metadata
    module Options
      extend ActiveSupport::Concern

      module ClassMethods
        def options
          @options ||= {}
        end

        def option(name, opts={})
          options[name] = opts
        end

        def inherited(subclass)
          # Allow subclasses to inherit options
          subclass.instance_variable_set(:@options, options.dup)
        end
      end
    end

  end
end
