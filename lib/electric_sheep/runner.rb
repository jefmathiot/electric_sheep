module ElectricSheep
  module Runner

    class SingleRun
      include Rescueable

      attr_reader :project
      attr_reader :logger

      def initialize(config, logger, project)
        @config=config
        @logger=logger
        @project=project
      end

      def run!
        has_been_rescued = rescued do
          @logger.info "Executing \"#{project.name}\""
          project.pipelined(project.starts_with) do |step, input|
            send("execute_#{executable_type(step)}", project, input, step)
          end
        end
        notify(project)
        return false if has_been_rescued
        @logger.info "Project \"#{project.name}\" completed in %.3f seconds" %
          project.execution_time.round(3)
        true
      end

      private
      def notify(project)
        project.notifiers.each do |metadata|
          rescued do
            metadata.agent_klazz.
              new(project, @config.hosts, logger, metadata).notify!
          end
        end
      end

      def executable_type(executable)
        executable.class.name.underscore.split('/').last
      end

      def execute_shell(project, input, metadata)
          Shell::LocalShell.new(
            @config.hosts.localhost, project, input, @logger
          ).perform!(metadata)
          metadata.last_output
      end

      def execute_remote_shell(project, input, metadata)
        Shell::RemoteShell.new(
          project.last_output.host,
          project,
          input,
          @logger,
          metadata.user
        ).perform!(metadata)
        metadata.last_output
      end

      def execute_transport(project, input, metadata)
        transport = metadata.agent_klazz.
          new(project, @logger, @config.hosts, input, metadata)
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
        @project = options[:project]
      end

      def run!
        if @project.nil?
          run_all!
        else
          run_single!
        end
      end

      protected
      def run_all!
        failures=[]
        @config.iterate do |project|
          failures << project.name unless run(project)
        end
        if failures.count > 0
          projects=failures.map{ |p| "\"#{p}\""}.join(', ')
          raise "Some projects have failed: #{projects}"
        end
      end

      def run_single!
        project=@config.queue.find{|p|p.id==@project}
        if project.nil?
          raise "Project \"#{@project}\" does not exist"
        else
          raise "Project #{project.id} has failed" unless run(project)
        end
      end

      def run(project)
        SingleRun.new(@config, @logger, project).run!
      end

    end
  end
end
