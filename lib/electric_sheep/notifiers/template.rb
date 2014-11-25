require 'erb'

module ElectricSheep
  module Notifiers
    class Template

      def initialize(type, ext=nil)
        # Trim mode omit newline for lines starting with <% and ending in %>
        @renderer = ERB.new(template(type, ext), nil, '<>')
      end

      def render(context)
        @renderer.result(Binding.new(context).get_binding)
      end

      protected
      def template(type, ext)
        path=File.join(ElectricSheep.template_path, type)
        path << ".#{ext}" if ext
        raise "Unable to find template #{path}" unless File.exists?(path)
        File.read path
      end

      class Binding
        def initialize(context)
          @context=context
        end

        def method_missing(m, *args, &block)
          if @context.has_key?(m)
           @context[m]
          else
            super
          end
        end

        # Access to the private binding method
        def get_binding
          binding
        end
      end

    end
  end
end
