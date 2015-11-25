module ElectricSheep
  module Metadata
    class RemoteShell < Shell
      option :host, required: true
      option :user, required: true

      def validate
        ensure_known_host
        super
      end

      protected

      def ensure_known_host
        return unless host && config.hosts.get(host).nil?
        errors.add(:host, "Unknown host with id #{host}")
      end
    end
  end
end
