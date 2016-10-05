module ElectricSheep
  module Agent
    extend ActiveSupport::Concern
    include Metadata::Options

    attr_reader :logger

    protected

    def option(name)
      @metadata.send(name)
    end
  end
end
