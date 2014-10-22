require 'active_support/core_ext'

module ElectricSheep
  class Runner
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
      @config.each_item do |project|
        execute_project(project)
      end
    end

    def run_single!
      project=@config.all.find{|p|p.id==@project}
      if project.nil?
        @logger.warn "Project \"#{@project}\" does not exist"
      else
        execute_project(project)
      end
    end

    def execute_project(project)
      project.benchmarked do
        @logger.info project.description ?
          "Executing \"#{project.description}\" (#{project.id})" :
          "Executing #{project.id}"
        project.each_item do |step|
          begin
            send("execute_#{executable_type(step)}", project, step)
          rescue Exception => e
            @logger.info "The last command failed :"
            @logger.info e.message
            @logger.debug e.backtrace
            @logger.error "Aborting project \"#{project.id}\""
            return
          end
        end
        @logger.success "Project \"#{project.id}\""
      end
    end

    def executable_type(executable)
      executable.class.name.underscore.split('/').last
    end

    def execute_shell(project, metadata)
      metadata.benchmarked do
          Shell::LocalShell.new(
            @config.hosts.localhost, project, @logger
          ).perform!(metadata)
      end
    end

    def execute_remote_shell(project, metadata)
      metadata.benchmarked do
        Shell::RemoteShell.new(
          project.last_product.host,
          project,
          @logger,
          metadata.user
        ).perform!(metadata)
      end
    end

    def execute_transport(project, metadata)
      transport = metadata.agent.new(project, @logger, metadata, @config.hosts)
      metadata.benchmarked do
        transport.perform!
      end
    end
  end
end
