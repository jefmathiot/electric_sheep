module ElectricSheeps
  module Metadata
    class Transport
      include Options

      options :from, :to

    end

    class TransportEnd
      include Options

      options :host, :resource

    end
  end
end
