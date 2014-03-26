module ElectricSheeps
  class Config
    include Queue

    attr_reader :hosts

    def initialize
      @hosts = Metadata::Hosts.new
      reset!
    end

  end
end
