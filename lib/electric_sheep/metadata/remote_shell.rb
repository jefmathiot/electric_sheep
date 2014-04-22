module ElectricSheep
  module Metadata
    class RemoteShell < Shell

      property :host, required: true
      property :user, required: true

      def validate(config)
        ensure_known_host(config)
        super
      end

      protected
      def ensure_known_host(config)
        if host && config.hosts.get(host).nil?
          errors.add(:host, "Unknown host with id #{host}")
        end
      end

    end
  end
end
