module ElectricSheep
  module Notifiers
    class Email
      include Notifier

      register as: "email"

      def notify
      end

    end
  end
end
