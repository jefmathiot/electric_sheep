module ElectricSheep
  module Interactors
    class Base
      delegate :expand_path, to: :directories

      attr_reader :session, :directories

      def initialize(host, job, logger = nil)
        @host = host
        @job = job
        @logger = logger
        @directories = Helpers::Directories.new(host, job, self)
      end

      def after_exec(&_block)
        yield.tap do |result|
          unless (result[:exit_status]).to_i.zero?
            if result[:err].empty?
              raise 'Command terminated with exit status: ' +
                    result[:exit_status].to_s
            else
              raise result[:err]
            end
          end
        end
      end

      def in_session(&_block)
        @session = build_session
        @directories.mk_job_directory!
        yield if block_given?
        close
      end

      def close; end

      def delete!(resource)
        Helpers::FSUtil.delete! self, expand_path(resource.path)
      end

      protected

      def _exec(*cmd)
        @logger.debug cmd.map(&:to_s).join if @logger
        after_exec do
          yield cmd.map { |chunk| _arg(chunk) }.join
        end
      end

      def _arg(chunk)
        chunk.respond_to?(:raw) ? chunk.raw : chunk
      end
    end
  end
end
