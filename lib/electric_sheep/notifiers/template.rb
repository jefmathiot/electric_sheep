require 'erb'

module ElectricSheep
  module Notifiers
    class Template
      def initialize(type)
        # Trim mode omit newline for lines starting with <% and ending in %>
        @renderer = ERB.new(template(type), nil, '<>')
      end

      def render(context)
        @renderer.result(Binding.new(context).get_binding)
      end

      protected

      def template(type)
        path = File.join(ElectricSheep.template_path, type)
        path << '.erb'
        fail "Unable to find template #{path}" unless File.exist?(path)
        File.read path
      end

      class Binding
        def initialize(context)
          @context = context
        end

        def method_missing(m, *args, &block)
          if @context.key?(m)
            @context[m]
          else
            super
          end
        end

        def to_date(datetime)
          datetime.strftime('%Y-%m-%d')
        end

        def to_time(datetime)
          datetime.strftime('%H:%M:%S')
        end

        def to_timezone(datetime)
          datetime.zone
        end

        def to_duration(seconds)
          minutes, seconds = seconds.divmod(60)
          hours, minutes = minutes.divmod(60)
          format '%dh%dm%ds', hours, minutes, seconds
        end

        def asset(path)
          "#{assets_url}/#{path}"
        end

        def partial(basename, context)
          Template.new(basename).render(context.merge(assets_url: assets_url))
        end

        # Access to the private binding method
        def get_binding
          binding
        end
      end
    end
  end
end
