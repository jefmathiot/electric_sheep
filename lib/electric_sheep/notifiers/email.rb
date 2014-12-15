module ElectricSheep
  module Notifiers
    class Email
      include Notifier

      register as: "email"

      def notify
        message = Mail.new do
          from option(:from)
          to option(:to)
          subject
          # TODO add the log
        end
      end

      protected
      def email_subject()
        project.successful? ? "Backup successful: #{project.id}" :
          "BACKUP FAILED: #{project.id}"
      end

    end
  end
end
