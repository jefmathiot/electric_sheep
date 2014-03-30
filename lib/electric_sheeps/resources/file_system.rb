module ElectricSheeps
  module Resources
    module FileSystem
      extend ActiveSupport::Concern
      include Resource

      included do
        options :path, :remote
      end
     
      def remote?
        remote == true
      end
    end
  end
end
