module ElectricSheep
  module Helpers
    module ShellStat
      extend ActiveSupport::Concern

      included do
        alias :stat_file :stat_filesystem
        alias :stat_directory :stat_filesystem
      end

      def stat_filesystem(resource)
        exec("du -bs #{expand_path(resource.path)} | cut -f1")[:out].chomp.to_i
      end

      def stat(resource)
        resource.stat.size || resource.stat!(send("stat_#{resource.type}", resource))
      end

    end
  end
end
