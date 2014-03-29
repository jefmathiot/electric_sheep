require 'shellwords'

module ElectricSheeps
  module Helpers
    module ShellSafe

      def shell_safe(expression)
        Shellwords.escape(expression)
      end

    end
  end
end
