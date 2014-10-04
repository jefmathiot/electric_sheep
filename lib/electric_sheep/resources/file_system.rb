module ElectricSheep
  module Resources
    class FileSystem < Resource
      include Named

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

    end
  end
end
