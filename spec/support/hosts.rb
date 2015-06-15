module Support
  module Hosts
    def new_host
      @hosts ||= ElectricSheep::Metadata::Hosts.new
      host_id = next_host
      @hosts.add(host_id, hostname: "#{host_id}.tld")
    end

    private

    def next_host
      @host_counter = @host_counter ? @host_counter + 1 : 1
      "host-#{@host_counter}"
    end
  end
end
