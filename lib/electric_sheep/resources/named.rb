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
        basename, extension = ::File.basename(path), nil
        while (part=::File.extname(basename)) != ""
          extension ||= ""
          extension="#{part}#{extension}"
          basename=::File.basename(basename, part)
        end
        names=Pathname.new(path).split
        parent=names.first.to_s
        {parent: parent, basename: basename, extension: extension}
      end

    end
  end
end