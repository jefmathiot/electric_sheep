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

        private

        def execute_project(project)
           @logger.info project.description ?
               "Executing \"#{project.description}\" (#{project.id})" :
               "Executing #{project.id}"
            project.each_item do |step|
                send("execute_#{executable_type(step)}", step)
            end
        end

        def executable_type(executable)
            executable.class.name.underscore.split('/').last
        end

        def execute_shell(shell_config)
            shell = Shell::LocalShell.new(@logger)
            shell.open!
            shell_config.each_item do |command_metadata|
                command = Agents::Register.command(command_metadata.agent).new(
                    logger: @logger,
                    shell: shell
                )
                command.run(command_metadata)
            end
            shell.close!
        end

    end
end
