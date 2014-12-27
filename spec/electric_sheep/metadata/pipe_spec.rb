require 'spec_helper'

describe ElectricSheep::Metadata::Pipe do

  PipeKlazz=Class.new do
    include ElectricSheep::Metadata::Pipe
  end

  describe PipeKlazz do
    [:item1, :item2, :resource, :start_location].each do |m|
      let(m){mock}
    end

    let(:pipe){ subject.new }

    describe 'pipelining' do

      before do
        resource.expects(:to_location).returns(start_location)
      end

      it 'stores its input and start location' do
        pipe.pipelined(resource)
        pipe.input.must_equal resource
        pipe.start_location.must_equal start_location
      end

      it 'creates a report using the input and start location' do
        ElectricSheep::Metadata::Pipe::Report.expects(:new).
          with(resource, start_location).returns(report=mock)
        pipe.pipelined(resource)
        pipe.report.must_equal report
      end

      it 'uses the parent report if provided' do
        pipe.pipelined(resource, mock(report: parent_report=mock))
        pipe.report.must_equal parent_report
      end

      describe 'iterating through its queue' do

        [:products, :outputs, :resources].each do |array|
          let(array){ [] }
        end

        before do
          [item1, item2].each do |item|
            pipe.add item
            products << mock
            outputs << mock
          end
        end

        def execute_pipeline
          pipe.pipelined(resource) do |item, resource|
            resources << resource
            index = item==item1 ? 0 : 1
            [products[index], outputs[index]]
          end
        end

        it 'retains the original input and start location' do
          execute_pipeline
          pipe.input.must_equal resource
          pipe.start_location.must_equal start_location
        end

        it 'yields the previous product to each block' do
          execute_pipeline
          resources.must_equal [resource, outputs.first]
        end

        it 'reports' do
          [item1, item2].each_with_index do |item, i|
            pipe.report.expects(:step).
              with(item, products[i], outputs[i])
          end
          execute_pipeline
        end

        it 'returns the last product' do
          execute_pipeline
          pipe.last_product.must_equal products.last
        end

      end

    end

  end

  describe ElectricSheep::Metadata::Pipe::Report do

    [:resource, :start_location, :alt_location, :product].each do |m|
      let(m){ mock }
    end

    let(:report){ subject.new(resource, start_location) }

    it 'appends the input resource and start location to the stack' do
      report.stack.first.location.must_equal start_location
      report.stack.first.steps.first.tap do |step|
        step.type.must_equal :resource
        step.payload.must_equal resource
      end
    end

    it 'ignores non-agent metadata' do
      report.step(Object.new, nil, nil)
      report.stack.size.must_equal 1
      report.stack.first.steps.size.must_equal 1
    end


    def assert_step(step, type, payload)
      step.type.must_equal type
      step.payload.must_equal payload
    end

    let(:command){ ElectricSheep::Metadata::Command.new }

    describe 'appending a command to the stack' do


      def step
        report.step(command, product, product)
      end

      it 'keeps the same location' do
        product.stubs(:to_location).returns(start_location)
        step
        report.stack.size.must_equal 1
        assert_step report.stack.first.steps[1], :command, command
        assert_step report.stack.first.steps.last, :resource, product
      end

      # TODO Should we exclude that weird case ? It's not supposed to happen, as
      # commands do not change resources locations
      it 'changes the location on the mainstream branch' do
        product.stubs(:to_location).returns(alt_location)
        step
        report.stack.size.must_equal 2
        report.stack.last.location.must_equal alt_location
        report.stack.last.branch.must_equal 'mainstream'
        assert_step report.stack.first.steps.last, :command, command
        assert_step report.stack.last.steps.first, :resource, product
      end

    end

    describe 'appending a transport to the stack' do

      let(:transport){ ElectricSheep::Metadata::Transport.new }

      def step(output)
        report.step(transport, product, output)
      end

      before do
        product.stubs(:to_location).returns(alt_location)
      end

      def assert_transport_steps(location, branch)
        assert_step report.stack[1], :transport, transport
        report.stack.last.location.must_equal location
        report.stack.last.branch.must_equal branch
        report.stack.last.steps.size.must_equal 1
        assert_step report.stack.last.steps.first, :resource, product
      end

      it 'changes the location on the mainstream branch' do
        step(product)
        report.stack.size.must_equal 3
        assert_transport_steps alt_location, 'mainstream'
      end

      describe 'forking' do

        let(:output){ mock.tap{ |m| m.stubs(:to_location).returns(mock) } }

        it 'doesnt restart' do
          step(output)
          report.stack.size.must_equal 3
          assert_transport_steps alt_location, 'fork'
        end

        it 'restarts to the reference resource' do
          next_resource=mock(to_location: output.to_location)
          step(output)
          report.step(command, next_resource, next_resource)
          report.stack.size.must_equal 4
          report.stack.last.location.must_equal output.to_location
          assert_step report.stack.last.steps.first, :resource, output
          assert_step report.stack.last.steps[1], :command, command
          assert_step report.stack.last.steps.last, :resource, next_resource
        end

      end

    end


    describe ElectricSheep::Metadata::Pipe::Report::WrapperStep do

      it 'initializes with empty steps' do
        subject.new(start_location, 'branch').tap do |step|
          step.location.must_equal start_location
          step.branch.must_equal 'branch'
          step.steps.must_equal []
        end
      end

      it 'uses provided steps if any' do
        subject.new(nil, nil, steps=[mock, mock]).
          steps.must_equal steps
      end

      describe 'with steps' do

        [:command, :transport, :resource].each do |m|
          let(m){ ElectricSheep::Metadata::Pipe::Report::SimpleStep.new(m) }
        end

        let(:wrapper){
          subject.new(nil, nil, [command, transport, resource])
        }

        it 'filters resources' do
          wrapper.resources.must_equal [resource]
        end

        it 'filters agents' do
          wrapper.agents.must_equal [command, transport]
        end

      end

    end

  end

end
