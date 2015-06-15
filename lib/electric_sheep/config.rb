module ElectricSheep
  class Config
    include Queue

    attr_reader :hosts
    attr_accessor :encryption_options, :decryption_options, :ssh_options

    def initialize
      @hosts = Metadata::Hosts.new
    end
  end
end
