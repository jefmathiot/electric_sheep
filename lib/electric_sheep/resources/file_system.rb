module ElectricSheep
  module Resources
    class FileSystem < Resource

      option :parent, required: true
      option :basename, required: true

      def initialize(opts)
        if path=opts.delete(:path)
          opts.merge!(normalize_path(path))
        end
        super
      end

      def remote?
        !local?
      end

      def local?
        host.nil? || host.local?
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
          extension ||= "" << part
          basename=::File.basename(basename, extension)
        end
        parent=::File.dirname(path) if Pathname.new(path).absolute?
        {parent: parent, basename: basename, extension: extension}
      end

    end
  end
end
