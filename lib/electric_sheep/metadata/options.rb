module ElectricSheep
  module Metadata
    module Options
      extend ActiveSupport::Concern

      def errors
        @errors ||= Errors.new
      end

      def options
        self.class.options
      end

      def validate(config)
        self.options.each do |option, opts|
          ensure_present(option) if opts[:required]
        end
        errors.empty?
      end

      def method_missing(method, *args, &block)
        if option?(method)
          @options[method]
        else
          super
        end
      end

      def respond_to?(method, include_all=false)
        if option?(method)
          true
        else
          super
        end
      end

      protected
      def option?(method)
        self.options.include?(method)
      end

      def option(name)
        @options[name]
      end

      def ensure_present(opt)
        if option(opt).nil?
          errors.add(opt, "Option #{opt} is required")
        end
      end

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

    class Errors

      def initialize
        @errors = {}.with_indifferent_access
      end

      def add(option, message, caused_by=Errors.new)
        @errors[option] ||= []
        @errors[option] << {message: message, caused_by: caused_by}
      end

      def [](option)
        @errors[option]
      end

      def empty?
        @errors.empty?
      end

    end
  end
end
