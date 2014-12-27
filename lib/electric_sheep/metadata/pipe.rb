module ElectricSheep
  module Metadata
    module Pipe
      include Queue
      include Monitor

      attr_reader :input, :start_location

      def pipelined(resource, parent=nil, &block)
        @report=parent.report unless parent.nil?
        init(resource)
        monitored do
          iterate do |item|
            begin
              result=yield(item, last_output)
            ensure
              if result.is_a?(Array)
                done!( item,  *result)
              else
                done!( item,  result, result)
              end
            end
          end
        end
      end

      def last_output
        @last_output || input
      end

      def last_product
        @last_product
      end

      def report
        @report ||= Report.new(input, start_location)
      end

      protected

      def done!(metadata, product, output)
        @last_output = output
        @last_product = product
        report.step metadata, product, output
      end

      def init(resource)
        @input=resource
        @start_location=resource.to_location
      end

      Location=Struct.new(:id, :location, :type)

      class Report

        def initialize(resource, location)
          step = SimpleStep.new(:resource, resource)
          @stack = [WrapperStep.new(location, 'mainstream', [ step ])]
        end

        def stack
          @stack
        end

        def step( metadata, product, output )
          return unless metadata.is_a?(Metadata::Agent)
          if @reference
            append_resource(@reference, true)
            @reference=nil
          end
          if metadata.is_a?(Metadata::Transport)
            @stack << SimpleStep.new(:transport, metadata)
          else
            @stack.last.steps << SimpleStep.new(:command, metadata)
          end
          if product != output
            if product.to_location != output.to_location
              change_location(product.to_location, 'fork')
            end
            append_resource(product)
            @reference=output
          else
            append_resource(output, true)
          end
        end

        private

        def append_resource(resource, change_location=false)
          if resource
            change_location(resource.to_location) if change_location
            @stack.last.steps << SimpleStep.new(:resource, resource)
          end
        end

        def change_location(location, branch='mainstream')
          last=@stack.last
          unless last.respond_to?(:location) && last.location==location
            @stack << WrapperStep.new(location, branch)
          end
        end

        SimpleStep=Struct.new(:type, :payload)

        class WrapperStep

          attr_reader :location, :branch, :steps

          def initialize(location, branch, steps=[])
            @location=location
            @branch=branch
            @steps=steps
          end

          def resources
            steps.select{|step| step.type==:resource}
          end

          def agents
            steps.select{|step| [:command, :transport].include?(step.type) }
          end

        end

      end

    end

  end
end
