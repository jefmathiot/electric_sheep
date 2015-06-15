module ElectricSheep
  module Commands
    module DeleteSource
      extend ActiveSupport::Concern

      included do
        option :delete_source
      end

      protected

      def delete_source!(input_path)
        return unless option(:delete_source)
        shell.exec "rm -rf #{input_path}"
        input.transient!
      end
    end
  end
end
