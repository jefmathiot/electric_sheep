require 'active_support/core_ext'

module ElectricSheep
  class Runner
    def initialize(options)
      @config = options[:config]
      @logger = options[:logger]
      @project = options[:project]
    end

    def run!
      have_run = false
      @config.each_item do |project|
        if @project.nil? || @project == project.id
          have_run = true
          execute_project(project)
        end
      end
      unless have_run
        if @project.nil?
          @logger.warn "No project available"
        else
          @logger.warn "Project \"#{@project}\" not present in sheepfile"
        end
      end

    end

    protected

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
