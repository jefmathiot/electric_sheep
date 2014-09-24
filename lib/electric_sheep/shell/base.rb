module ElectricSheep
  module Shell
    class Base
      delegate :project_directory, to: :directories
      delegate :mk_project_directory!, to: :directories
      delegate :expand_path, to: :directories
      delegate :session, to: :interactor
      attr_reader :interactor

      def directories
        @directories||=Helpers::Directories.new(@host, @project, @interactor)
      end

      def exec(cmd)
        raise "Shell not opened" unless opened?
        @interactor.exec(cmd, @logger)
      end

      def opened?
        !!@interactor
      end

    end
  end
end