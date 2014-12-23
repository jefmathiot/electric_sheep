require 'net/scp'

module ElectricSheep
  module Transports
    class SCP
      include Transport

      register as: "scp"

      option :as

      def remote_interactor
        @remote_interactor ||= Interactors::SshInteractor.new(
          input.local? ? host(option(:to)) : input.host,
          @project,
          option(:as),
          @logger
        )
      end

      def remote_resource
        send("#{input.type}_resource", host(option(:to)))
      end

    end
  end
end
