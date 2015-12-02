require 'spec_helper'
describe ElectricSheep::Commands::Compression::TarGz do
  include Support::Command

  it { defines_options :delete_source }

  it 'should have registered as "tar_gz"' do
    ElectricSheep::Agents::Register.command('tar_gz').must_equal subject
  end

  def expects_log
    logger.expects(:info).in_sequence(seq).with(
      regexp_matches(%r{^Compressing \/tmp\/some-\w+ to some-\w+.tar.gz$})
    )
  end

  def self.describe_compression(input_type, delete_source = false)
    describe "with a #{input_type} as the input " \
      "(delete source: #{delete_source})" do
      executing do
        let(:output_name) { "some-#{input_type}-20140605-040302" }
        let(:output_ext) { '.tar.gz' }
        let(:output_type) { :file }
        let(:input) { send(input_type, "/tmp/some-#{input_type}") }

        it "compresses the provided #{input_type}" do
          escapes input.path, output_path
          metadata.expects(:delete_source).returns(delete_source)
          cmds = [
            "cd #{File.dirname(input.path)}; " \
            "tar -cvzf #{safe_output_path} " \
            "#{File.basename(input.path)} 1>&2"
          ]
          cmds << "rm -rf #{input.path}" if delete_source
          shell.expects(:expand_path).at_least(1).with(input.path)
            .returns(input.path)
          expects_stat(input_type, input, 4096)
          ensure_execution(*cmds)
          input.transient?.must_equal true if delete_source
        end
      end
    end
  end

  describe_compression :file
  describe_compression :directory
  describe_compression :file, true
  describe_compression :directory, true
end
