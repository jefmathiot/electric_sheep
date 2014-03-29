module ElectricSheeps
  module Commands
    module Command
      extend ActiveSupport::Concern

      attr_reader :logger, :shell, :work_dir

      module ClassMethods
        def register(options={})
          ElectricSheeps::Commands::Register.register(self, options)
        end

        def resource(name, options={})
          resources[name] = options[:kind_of] || Resources::File
        end

        def resources
          @resources ||= {}
        end
      end

      def initialize(logger, shell, work_dir, resources)
        @logger = logger
        @shell = shell
        @work_dir = work_dir

        resources.each { |key, value|
          self.class.send :attr_reader, key
          self.instance_variable_set "@#{key}", value
        } unless resources.nil?
      end

    end
  end
end
