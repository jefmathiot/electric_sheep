module ElectricSheeps
  module Metadata
    class Project
      include Queue
      include Metered

      attr_accessor :description

      def initialize
        reset!
      end

      include Options
      options :id

    end
  end
end
