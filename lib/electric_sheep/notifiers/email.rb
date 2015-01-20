require 'mail'
require 'premailer'

module ElectricSheep
  module Notifiers
    class Email
      include Notifier

      register as: "email"

      option :from, required: true
      option :to, required: true
      # Delivery method
      option :using, required: true
      # Delivery options
      option :with

      def notify!
        msg = Mail.new
        msg.from option(:from)
        msg.to option(:to)
        msg.subject subject
        msg.html_part = Mail::Part.new.tap do |part|
          part.content_type 'text/html; charset=UTF-8'
          part.body html_body
        end
        deliver(msg)
      end

      protected

      def subject
        job.successful? ? "Backup successful: #{job.name}" :
          "BACKUP FAILED: #{job.name}"
      end

      def html_body
        html = preflight(Template.new('email.html').
          render(
            job: job,
            assets_url: assets_url,
            time: Time.now.getlocal,
            timezone: Time.now.getlocal.zone,
            hostname: `hostname`.chomp
          )
        )
      end

      def preflight(body)
        Premailer.new(body, with_html_string: true).to_inline_css
      end

      def deliver(msg)
        # Mail expects option keys as symbols
        msg.delivery_method option(:using), symbolize(option(:with))
        msg.deliver
      end

      def assets_url
        "http://assets.electricsheep.io/#{ElectricSheep::VERSION}/" +
          "notifiers/email"
      end

      def symbolize(options)
        if options
          options.reduce({}) do |h, (k, v)|
            h[k.to_sym]=v
            h
          end
        end
      end

    end
  end
end
