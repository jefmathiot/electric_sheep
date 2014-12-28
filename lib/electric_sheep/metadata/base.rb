module ElectricSheep
  module Metadata
    class Base
      include Options

      def initialize(opts={})
        @options = opts
      end

      def errors
        @errors ||= Errors.new
      end

      def options
        self.class.options
      end

      def validate(config)
        options.each do |option, opts|
          ensure_present(option) if opts[:required]
        end
        errors.empty?
      end

      def method_missing(method, *args, &block)
        if option?(method)
          option(method)
        else
          super
        end
      end

      def respond_to?(method, include_all=false)
        option?(method) || super
      end

      def option(name)
        @options[name]
      end

      def option?(method)
        options.include?(method)
      end

      protected

      def ensure_present(opt)
        if option(opt).nil?
          errors.add(opt, "Option #{opt} is required")
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
