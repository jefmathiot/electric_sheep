require 'spec_helper'

describe ElectricSheep::Sheepfile::Evaluator do
  let(:path) { File.expand_path('Sheepfile') }

  def expects_open(file, contents)
    File.expects(:open).with(file, 'rb').returns mock(read: contents)
  end

  def expects_readable(file)
    File.expects(:exist?).with(file).returns true
    File.expects(:readable?).with(file).returns true
  end

  it 'raises if configuration file does not exist' do
    File.expects(:exist?).with(path).returns false
    -> { subject.new('Sheepfile').evaluate }.must_raise RuntimeError
  end

  it 'raises if configuration file is not readable' do
    File.expects(:exist?).with(path).returns true
    File.expects(:readable?).with(path).returns false
    -> { subject.new('Sheepfile').evaluate }.must_raise RuntimeError
  end

  describe 'with a readable file' do
    before do
      expects_readable(path)
    end

    it 'evaluates file contents in DSL' do
      contents = <<-EOS
      host "some-host", hostname: "some-host.tld"
      EOS
      expects_open(path, contents)
      config = subject.new('Sheepfile').evaluate
      config.hosts.get('some-host').hostname.must_equal 'some-host.tld'
    end

    it 'raises on syntax error' do
      contents = <<-EOS
      host "some-host", hostname: "some-host.tld
      host "some-host-2",, hostname: "some-host.tld"
      EOS
      expects_open(path, contents)

      err = lambda do
        subject.new('Sheepfile').evaluate
      end.must_raise ElectricSheep::SheepException
      err.message.must_match(/Syntax error in .*Sheepfile line: 2/)
    end
  end

  describe 'loading files' do
    def expects_file_evaluation(config, path)
      expects_readable(path)
      expects_open(path, 'job "my-job" do; end')
      config.expects(:add).with(kind_of(::ElectricSheep::Metadata::Job))
    end

    def expects_single_file_loading(provided_path, expected_path)
      File.expects(:directory?).with(expected_path).returns(false)
      mock.tap do |config|
        expects_file_evaluation(config, expected_path)
        subject.new('Sheepfile').load(config, provided_path)
      end
    end

    it 'loads a single file relatively to the current directory' do
      path = File.join(File.expand_path('.'), 'file')
      expects_single_file_loading 'file', path
    end

    it 'loads a single file using its absolute path' do
      expects_single_file_loading '/tmp/file', '/tmp/file'
    end

    it 'loads multiple files in a directory' do
      path = File.join(File.expand_path('.'), 'dir')
      files = %w(f1 f2 f3).map { |f| File.join(path, f) }
      File.expects(:directory?).with(path).returns(true)
      Dir.expects(:glob).with("#{path}/*").returns(files)
      mock.tap do |config|
        files.each do |f|
          expects_file_evaluation(config, f)
        end
        subject.new('Sheepfile').load(config, 'dir')
      end
    end
  end
end
