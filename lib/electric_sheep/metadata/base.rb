module ElectricSheep
  module Metadata
    class Base
      include Properties

      def initialize(options={})
        @options = options
      end

      def errors
        @errors ||= Errors.new
      end

      def validate(config)
        self.class.properties.each do |property, opts|
          ensure_present(property) if opts[:required]
        end
        errors.empty?
      end

      def method_missing(method, *args, &block)
        if property?(method)
          option = @options[method]
        else
          super
        end
      end

      def respond_to?(method, include_all=false)
        if property?(method)
          true
        else
          super
        end
      end

      protected
      def property?(method)
        self.class.properties.include?(method)
      end

      def ensure_present(property)
        if @options[property].nil?
          errors.add(property, "Property #{property} is required")
        end
      end

    end

    class Errors

      def initialize
        @errors = {}.with_indifferent_access
      end

      def add(property, message, caused_by=Errors.new)
        @errors[property] ||= [] 
        @errors[property] << {message: message, caused_by: caused_by}
      end

      def [](property)
        @errors[property]
      end

      def empty?
        @errors.empty?
      end

    end
  end
end
