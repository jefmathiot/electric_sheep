module ElectricSheep
  module Runner
    class SingleRun
      include Rescueable

      attr_reader :job
      attr_reader :logger

      def initialize(config, logger, job)
        @config = config
        @logger = logger
        @job = job
      end

      def run!
        has_been_rescued = rescue_job
        notify(job)
        return false if has_been_rescued
        @logger.info format("job \"#{job.name}\" completed in %.3f seconds",
                            job.execution_time.round(3))
        true
      end

      private

      def notify(job)
        job.notifiers.each do |metadata|
          rescued do
            metadata.agent_klazz
                    .new(job, @config.hosts, logger, metadata).notify!
          end
        end
      end

      def rescue_job
        rescued do
          @logger.info "Executing \"#{job.name}\""
          job.pipelined(job.starts_with) do |step, input|
            send("execute_#{executable_type(step)}", job, input, step)
          end
        end
      end

      def executable_type(executable)
        executable.class.name.demodulize.underscore
      end

      def execute_shell(job, input, metadata)
        Shell::LocalShell.new(
          @config.hosts.localhost, job, input, @logger
        ).perform!(metadata)
        metadata.last_output
      end

      def execute_remote_shell(job, input, metadata)
        Shell::RemoteShell.new(
          job.last_output.host,
          job,
          input,
          metadata.user,
          @logger
        ).perform!(metadata)
        metadata.last_output
      end

      def execute_transport(job, input, metadata)
        klazz = metadata.agent_klazz
        transport = klazz.new(job, @logger, @config.hosts, input, metadata)
        metadata.monitored do
          transport.run!
        end
        return transport.output, transport.product
      end
    end

    class Inline
      def initialize(options)
        @config = options[:config]
        @logger = options[:logger]
        @job = options[:job]
      end

      def run!
        if @job.nil?
          run_all!
        else
          run_single!
        end
      end

      protected

      def run_all!
        failures = []
        @config.iterate do |job|
          failures << job.name unless run(job)
        end
        return unless failures.count > 0
        jobs = failures.map { |p| "\"#{p}\"" }.join(', ')
        raise "Some jobs have failed: #{jobs}"
      end

      def run_single!
        job = @config.queue.find { |p| p.id == @job }
        raise "job \"#{@job}\" does not exist" if job.nil?
        raise "job #{job.id} has failed" unless run(job)
      end

      def run(job)
        SingleRun.new(@config, @logger, job).run!
      end
    end
  end
end
