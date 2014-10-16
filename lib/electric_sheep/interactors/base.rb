module ElectricSheep
  module Interactors
    class Base
      delegate :expand_path, to: :directories

      attr_reader :directories

      def initialize(host, project, logger=nil)
        @host=host
        @project = project
        @logger = logger
        @directories=Helpers::Directories.new(host, project, self)
      end

      def after_exec(&block)
        block.call.tap do |result|
          raise result[:err].empty? ? "... bââââââaa !?! (#{result[:exit_status]})" : result[:err] unless result[:exit_status] == 0
        end
      end

      def session
        unless @session
          @session=build_session
          @directories.mk_project_directory!
        end
        @session
      end

      def in_session(&block)
        session
        block.call if block_given?
        close
      end

      def close ; end

    end
  end
end
