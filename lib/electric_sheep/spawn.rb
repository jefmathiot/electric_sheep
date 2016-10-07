require 'posix/spawn'

module ElectricSheep
  module Spawn
    class << self
      def exec(cmd, logger = nil)
        result = {}
        child = POSIX::Spawn::Child.new(cmd)
        result[:out] = child_output(child, logger)
        result[:err] = child_error(child)
        result[:exit_status] = child.status
        result
      end

      private

      def child_output(child, logger)
        return '' if child.out.nil?
        child.out.chomp.tap do |output|
          logger&.debug(output)
        end
      end

      def child_error(child)
        return '' if child.err.nil?
        child.err.chomp
      end
    end
  end
end
