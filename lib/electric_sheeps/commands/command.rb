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
          resources[name] = { :kind_of => Resources::File }.merge!(options)
        end

        def prerequisite(*args)
          @prerequisites = args.dup
        end

        # Should be at least protected
        def resources
          @resources ||= {}
        end

        def prerequisites
          @prerequisites ||= []
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

      def check_prerequisites
        self.class.prerequisites.each { |prerequisite|
          raise Exception.new("Missing #{prerequisite} in #{self.class}") unless self.class.instance_methods(false).include?(prerequisite)
          self.send prerequisite
        }
      end
    end
  end
end
