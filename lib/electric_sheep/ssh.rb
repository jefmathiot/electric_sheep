require 'net/ssh'

module ElectricSheep
  module SSH
    def ssh_session(host, user, private_key, &block)
      Net::SSH.start(host.hostname, user,
          port: host.ssh_port,
          key_data: Crypto.get_key(private_key, :private).export,
          keys_only: true,
          &block)
    end
  end
end
