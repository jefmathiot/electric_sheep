module ElectricSheep
  module Interactors
    class Base
      def in_session(&block)
        session do
          block.call
        end
      end
    end
  end
end