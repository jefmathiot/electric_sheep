module ElectricSheep
  module Resources
    module Hosted
      extend ActiveSupport::Concern

      delegate :to_location, to: :host

      included do
        option :host, required: true
      end

    end
  end
end
