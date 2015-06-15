require 'pathname'

module ElectricSheep
  module Resources
    module Named
      extend ActiveSupport::Concern

      included do
        option :parent, required: true
        option :basename, required: true
      end

      def path
        ::File.join [parent, name].compact
      end

      def name
        name_items.compact.join
      end

      protected

      def name_items
        [basename].tap do |items|
          items << "-#{timestamp}" if timestamp?
        end
      end

      def normalize_path(path)
        split_name_parts(::File.basename(path))
          .merge(parent: Pathname.new(path).split.first.to_s)
      end

      def split_name_parts(basename)
        extension = nil
        if respond_to?(:extension)
          while (part = ::File.extname(basename)) != ''
            extension ||= ''
            extension = "#{part}#{extension}"
            basename = ::File.basename(basename, part)
          end
        end
        { basename: basename, extension: extension }
      end
    end
  end
end
