require 'active_support/core_ext'

module ElectricSheeps
    class Runner
        def initialize(options)
            @config = options[:config]
            @logger = options[:logger]
        end

        def run!
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
                project.each_item do |step|
                    send("execute_#{executable_type(step)}", step)
                end
            end
        end

        def executable_type(executable)
            executable.class.name.underscore.split('/').last
        end

        def execute_shell(metadata)
            metadata.benchmarked do
                execute_commands metadata, Shell::LocalShell.new(@logger)
            end
        end

        def execute_remote_shell(metadata)
            metadata.benchmarked do
                execute_commands metadata, Shell::RemoteShell.new(
                    @logger, @config.hosts.get(metadata.host).name, metadata.user
                )
            end
        end

        def execute_commands(shell_metadata, shell)
            shell.open!
            shell_metadata.each_item do |metadata|
                command = metadata.agent.new(
                    logger: @logger,
                    shell: shell
                )
                metadata.benchmarked do
                    command.run(metadata)
                end
            end
            shell.close!
        end

    end
end
