module ElectricSheeps
  module Helpers
    module Named
      include ShellSafe
      include Timestamps

      def with_named_dir(base_dir, name, options={})
        name = "#{name}-#{timestamp}" if options[:timestamp]
        File.join(base_dir, shell_safe(name)).tap do |dir|
          yield dir if block_given?
        end
      end

    end
  end
end
