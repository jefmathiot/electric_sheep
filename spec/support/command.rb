module Support
  module Command
    extend ActiveSupport::Concern
    include Options

    class NilMetadata
      # rubocop:disable MethodMissing
      def method_missing(_method, *_args, &_block)
        nil
      end
    end

    def file(path)
      ElectricSheep::Resources::File.new(path: path)
    end

    def directory(path)
      ElectricSheep::Resources::Directory.new(path: path)
    end

    def requires(*options)
      options.each do |option|
        subject.new(mock, mock, mock, mock, NilMetadata.new).tap do |subject|
          expects_validation_error(subject, option,
                                   "Option #{option} is required")
        end
      end
    end

    def expects_output_stat(size = 1024)
      expects_stat(output_type, kind_of(ElectricSheep::Resources::Resource),
                   size)
    end

    def expects_stat(type, resource, size = 1024)
      shell.expects("stat_#{type}").in_sequence(seq)
           .with(resource)
           .returns(size)
    end

    def assert_product(product)
      product.wont_be_nil
      product.path.must_equal "#{output_name}#{output_ext}"
      product.stat.size.must_equal 1024
    end

    def assert_command
      assert_product(command.run!)
      input.stat.size.must_equal 4096
    end

    def ensure_execution(*expected_cmds)
      Timecop.travel Time.utc(2014, 6, 5, 4, 3, 2) do
        expects_log
        expected_cmds.each do |cmd|
          shell.expects(:exec).in_sequence(seq)
               .with(*cmd)
        end
        expects_output_stat
        assert_command
      end
    end

    def escapes(*args)
      args.each do |arg|
        shell.stubs(:safe).with(arg).returns(Shellwords.escape(arg))
      end
    end

    module ClassMethods
      def ensure_registration(id)
        it "registers as \"#{id}\"" do
          ElectricSheep::Agents::Register.command(id).must_equal subject
        end
      end

      def executing(&block)
        describe 'executing the command' do
          let(:seq) { sequence('command_exec') }
          let(:output_ext) { nil }
          let(:command) { subject.new(job, logger, shell, input, metadata) }

          let(:job) do
            ElectricSheep::Metadata::Job.new(ElectricSheep::Config.new)
          end

          [:logger, :shell, :host, :metadata].each do |m|
            let(m) { mock }
          end

          let(:output_path) do
            "/job/dir/#{output_name}#{output_ext}"
          end

          let(:safe_output_path) do
            Shellwords.escape "/job/dir/#{output_name}#{output_ext}"
          end

          let(:shell) do
            mock.tap do |shell|
              shell.stubs(:host).returns(host)
              shell.expects(:expand_path).at_least(1).with(
                "#{output_name}#{output_ext}"
              ).returns(output_path)
            end
          end

          before do
            job.start_with! input
          end

          instance_eval(&block)
        end
      end
    end
  end
end
