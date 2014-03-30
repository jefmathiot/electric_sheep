module ElectricSheeps
  module Commands
    module Command
      extend ActiveSupport::Concern

      attr_reader :id, :logger, :shell, :work_dir
      
      def initialize(id, project, logger, shell, work_dir, resources)
        @id = id
        @logger = logger
        @shell = shell
        @work_dir = work_dir
        @project = project

        resources.each { |key, value|
          self.class.send :attr_reader, key
          self.instance_variable_set "@#{key}", value
        } unless resources.nil?
      end
      
      def check_prerequisites
        self.class.prerequisites.each { |prerequisite|
          raise "Missing #{prerequisite} in #{self.class}" unless self.respond_to?(prerequisite)
          self.send prerequisite
        }
      end

      protected
      def done!(resource)
        @project.store_product(id, resource)
      end

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

    end
  end
end
