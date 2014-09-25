module ElectricSheep
  module Shell
    class Base
      delegate :project_directory, :mk_project_directory!, :expand_path,
        :session, to: :interactor

      attr_reader :interactor

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