module Support
  module Command
    extend ActiveSupport::Concern
    include Options

    class NilMetadata
      def method_missing(method, *args, &block)
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

    def expects_output_stat
      expects_filesystem_stat(output_path)
    end

    def expects_filesystem_stat(path, size=1024)
      shell.expects(:exec).in_sequence(seq).
        with("du -bs #{path} | cut -f1").
        returns(out: size.to_s)
    end

    def assert_product
      product = project.last_product
      product.wont_be_nil
      product.path.must_equal "#{output_name}#{output_ext}"
      product.stat.size.must_equal 1024
    end

    def assert_command
      command.run!
      input.stat.size.must_equal 4096
      assert_product
    end

    def ensure_execution(*expected_cmds)
      Timecop.travel Time.utc(2014, 6, 5, 4, 3, 2) do
        expects_log
        expected_cmds.each do |cmd|
          shell.expects(:exec).in_sequence(seq).
            with(cmd)
        end
        expects_output_stat
        assert_command
      end
    end


    module ClassMethods
      def ensure_registration(id)
        it "registers as \"#{id}\"" do
          ElectricSheep::Agents::Register.command(id).must_equal subject
        end
      end

      def executing(&block)

        describe "executing the command" do

          let(:seq){sequence('command_exec')}
          let(:output_ext){ nil }
          let(:command){subject.new(project, logger, shell, metadata)}

          let(:project){ ElectricSheep::Metadata::Project.new }
          [:logger, :shell, :host, :metadata].each do |m|
            let(m){ mock }
          end

          let(:output_path){ "/project/dir/#{output_name}#{output_ext}" }

          let(:shell) do
            mock.tap do |shell|
              shell.stubs(:host).returns(host)
              shell.expects(:expand_path).at_least(1).with(
                "#{output_name}#{output_ext}"
              ).returns(output_path)
            end
          end

          before do
            project.start_with! input
          end

          instance_eval &block
        end

      end
    end
  end
end
