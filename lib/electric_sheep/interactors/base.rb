module ElectricSheep
  module Interactors
    class Base
      delegate :project_directory, :mk_project_directory!, :expand_path,
        to: :directories

      attr_reader :directories

      def initialize(host, project)
        @host=host
        @project = project
        @directories=Helpers::Directories.new(host, project, self)
      end

      def session
        @session||=build_session
        mk_project_directory!
      end

      def in_session(&block)
        session
        block.call
        close
      end

      def close ; end

    end
  end
end