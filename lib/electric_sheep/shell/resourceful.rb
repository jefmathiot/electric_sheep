module ElectricSheep
  module Shell
    module Resourceful

      def directory_resource(options)
        Resources::Directory.new(resource_options(options))
      end

      def file_resource(options)
        Resources::File.new(resource_options(options))
      end

      def resource_options(options)
        if local?
          options.merge(host: Metadata::Localhost.new)
        else
          options.merge(host: @host)
        end
      end
    end
  end
end
