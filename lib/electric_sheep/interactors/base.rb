module ElectricSheep
  module Interactors
    class Base
      delegate :expand_path, to: :directories

      attr_reader :session, :directories

      def initialize(host, job, logger=nil)
        @host=host
        @job = job
        @logger = logger
        @directories=Helpers::Directories.new(host, job, self)
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
        @directories.mk_job_directory!
        block.call if block_given?
        close
      end

      def close ; end

      def delete!(resource)
        Helpers::FSUtil.delete! self, expand_path(resource.path)
      end

    end
  end
end
