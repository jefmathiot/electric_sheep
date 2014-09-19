module ElectricSheep
  module Resources
    class Resource < Metadata::Base
      option :host, required: true
    end
  end
end
