module ElectricSheep
  module Metadata
    module Typed

      def type
        self.class.name.demodulize.underscore
      end

    end
  end
end
