module ElectricSheep
  module Metadata
    module Properties
      extend ActiveSupport::Concern

      module ClassMethods
        def properties
          @properties ||= {}
        end

        def property(name, options={})
          properties[name] = options
        end

        def inherited(subclass)
          # Allow subclasses to inherit properties
          subclass.instance_variable_set(:@properties, properties.dup)
        end
      end
    end
  end
end
