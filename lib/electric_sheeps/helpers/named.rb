module ElectricSheeps
  module Helpers
    module Named
      include ShellSafe
      include Timestamps

      def with_named_dir(*args, &block)
        with_named_path *args, &block
      end

      def with_named_file(*args, &block)
        with_named_path *args, &block
      end

      protected
      def with_named_path(base_dir, name, options={}, &block)
        name = "#{name}-#{timestamp}" if options[:timestamp]
        File.join(base_dir, shell_safe(name)).tap do |resource|
          yield resource if block_given?
        end
      end
    end
  end
end
