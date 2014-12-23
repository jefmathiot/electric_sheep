module ElectricSheep
  class Config
    include Queue

    attr_reader :hosts

    def initialize
      @hosts = Metadata::Hosts.new
    end

  end
end
