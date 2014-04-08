module ElectricSheep
  module Helpers
    module Named
      include ShellSafe
      include Timestamps

      def with_named_dir(base_dir, name, options={}, &block)
        options.delete(:extension)
        with_named_path base_dir, name, options, &block
      end

      def with_named_file(*args, &block)
        with_named_path *args, &block
      end

      protected
      def with_named_path(base_dir, name, options={}, &block)
        name = "#{name}-#{timestamp}" if options[:timestamp]
        name = "#{name}.#{options[:extension]}" if options.has_key?(:extension)
        File.join(base_dir, shell_safe(name)).tap do |resource|
          yield resource if block_given?
        end
      end
    end
  end
end
