module ElectricSheep
  module Metadata
    module Pipe
      include Queue
      include Monitor

      attr_reader :input, :start_location, :last_product

      def pipelined(resource, parent = nil, &block)
        @report = parent.report unless parent.nil?
        init(resource)
        monitored do
          iterate do |item|
            execute(item, &block)
          end
        end
      end

      def last_output
        @last_output || input
      end

      def report
        @report ||= Report.new(input, start_location)
      end

      protected

      def execute(item, &_)
        result = yield(item, last_output)
      ensure
        propagate(item, result)
      end

      def propagate(item, result)
        if result.is_a?(Array)
          done!(item, *result)
        else
          done!(item, result, result)
        end
      end

      def done!(metadata, product, output)
        @last_output = output
        @last_product = product
        report.step metadata, product, output
      end

      def init(resource)
        @input = resource
        @start_location = resource.to_location
      end

      Location = Struct.new(:id, :location, :type)

      class Report
        attr_reader :stack

        def initialize(resource, location)
          step = SimpleStep.new(:resource, resource)
          @stack = [WrapperStep.new(location, 'mainstream', [step])]
        end

        def step(metadata, product, output)
          return unless metadata.is_a?(Metadata::Agent)
          append_reference_resource
          push_agent(metadata)
          push_product(product, output)
        end

        private

        def append_reference_resource
          return unless @reference
          append_resource(@reference, true)
          @reference = nil
        end

        def push_agent(metadata)
          if metadata.is_a?(Metadata::Transport)
            @stack << SimpleStep.new(:transport, metadata)
          else
            @stack.last.steps << SimpleStep.new(:command, metadata)
          end
        end

        def push_product(product, output)
          if product != output
            if product.to_location != output.to_location
              change_location(product.to_location, 'fork')
            end
            append_resource(product)
            @reference = output
          else
            append_resource(output, true)
          end
        end

        def append_resource(resource, change_location = false)
          return unless resource
          change_location(resource.to_location) if change_location
          @stack.last.steps << SimpleStep.new(:resource, resource)
        end

        def change_location(location, branch = 'mainstream')
          last = @stack.last
          return if last.respond_to?(:location) && last.location == location
          @stack << WrapperStep.new(location, branch)
        end

        SimpleStep = Struct.new(:type, :payload)

        class WrapperStep
          attr_reader :location, :branch, :steps

          def initialize(location, branch, steps = [])
            @location = location
            @branch = branch
            @steps = steps
          end

          def resources
            steps.select { |step| step.type == :resource }
          end

          def agents
            steps.select { |step| [:command, :transport].include?(step.type) }
          end
        end
      end
    end
  end
end
