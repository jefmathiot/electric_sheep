require 'active_support/core_ext'

module ElectricSheeps
  class Runner
    def initialize(options)
      @config = options[:config]
      @logger = options[:logger]
    end

    def run!
      Directories.mk_work_dir!
      @config.each_item do |project|
        execute_project(project)
      end 
    end

    protected

    def execute_project(project)
      project.benchmarked do
        @logger.info project.description ?
          "Executing \"#{project.description}\" (#{project.id})" :
          "Executing #{project.id}"
          project_dir = Directories.mk_project_dir!(project)
          project.each_item do |step|
            send("execute_#{executable_type(step)}", step, project_dir)
          end
      end
    end

    def executable_type(executable)
      executable.class.name.underscore.split('/').last
    end

    def execute_shell(metadata, work_dir)
      metadata.benchmarked do
        execute_commands metadata, Shell::LocalShell.new(@logger), work_dir
      end
    end

    def execute_remote_shell(metadata, work_dir)
      metadata.benchmarked do
        execute_commands metadata, Shell::RemoteShell.new(
          @logger, @config.hosts.get(metadata.host).name, metadata.user
        ), work_dir
      end
    end

    def execute_commands(shell_metadata, shell, work_dir)
      shell.open!
      shell_metadata.each_item do |metadata|
        command = metadata.agent.new(
          logger: @logger,
          shell: shell,
          work_dir: work_dir
        )
        metadata.benchmarked do
          command.run(metadata)
        end
      end
      shell.close!
    end

  end
end
