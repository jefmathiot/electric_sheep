module ElectricSheep
  module Interactors
    class Base
      delegate :expand_path, to: :directories

      attr_reader :session, :directories

      def initialize(host, project, logger=nil)
        @host=host
        @project = project
        @logger = logger
        @directories=Helpers::Directories.new(host, project, self)
      end

      def after_exec(&block)
        block.call.tap do |result|
          unless result[:exit_status] == 0
            raise result[:err].empty? ?
              "Command terminated with exit status : #{result[:exit_status]}" :
              result[:err]
          end
        end
      end

      def in_session(&block)
        @session=build_session
        @directories.mk_project_directory!
        block.call if block_given?
        close
      end

      def close ; end

      def delete!(resource)
        exec "rm -rf #{expand_path(resource.path)}"
      end

    end
  end
end
