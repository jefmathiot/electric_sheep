module ElectricSheep
  module Resources
    class FileSystem < Resource
      include Named
      include Hosted

      def initialize(opts = {})
        if (path = opts.delete(:path))
          opts.merge!(normalize_path(path))
        end
        super
      end
    end
  end
end
