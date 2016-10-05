module ElectricSheep
  module Metadata
    module Options
      extend ActiveSupport::Concern

      def options
        self.class.options
      end

      def option(name)
        return unless option?(name)
        decrypt(fetch_option(name))
      end

      def option?(method)
        options.include?(method)
      end

      protected

      def fetch_option(name)
        explicit_option(name) || default_option(name)
      end

      def decrypt(option)
        return option.decrypt if option.respond_to?(:decrypt)
        option
      end

      def explicit_option(name)
        @options[name]
      end

      def default_option(name)
        option?(name) && options[name][:default]
      end

      module ClassMethods
        def options
          @options ||= {}
        end

        def option(name, opts = {})
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
