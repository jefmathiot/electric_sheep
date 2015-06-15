module ElectricSheep
  module Resources
    class Stat
      extend ActiveSupport::NumberHelper

      attr_accessor :size

      def initialize(size = nil)
        @size = size
      end

      def humanize
        size && self.class.number_to_human_size(size) || 'Unknown'
      end
    end
  end
end
