module ElectricSheep
  module Metadata
    class Shell < Base
      include Pipe
      include Monitor

      def initialize(options={})
        super
      end

      def validate(config)
        iterate do |command|
          unless command.validate(config)
            errors.add(:base, "Invalid command #{command.action}", command.errors)
          end
        end
        super
      end

    end
  end
end
