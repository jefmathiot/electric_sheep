module ElectricSheep
  module Metadata
    class Base
      include Options

      def initialize(opts = {})
        @options = opts
      end

      def errors
        @errors ||= Errors.new
      end

      def validate
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

      def respond_to?(method, include_all = false)
        option?(method) || super
      end

      protected

      def ensure_present(opt)
        errors.add(opt, "Option #{opt} is required") if option(opt).nil?
      end
    end

    class Errors
      def initialize
        @errors = {}.with_indifferent_access
      end

      def add(option, message, caused_by = Errors.new)
        @errors[option] ||= []
        @errors[option] << { message: message, caused_by: caused_by }
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
