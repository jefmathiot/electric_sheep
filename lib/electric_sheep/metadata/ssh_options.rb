module ElectricSheep
  module Metadata
    class SshOptions < Base
      option :host_key_checking, default: 'standard'
      option :known_hosts, default: '~/.ssh/known_hosts'
    end
  end
end
