require 'spec_helper'
require 'shellwords'

describe ElectricSheep::Crypto do
  it 'returns the GPG encryption module' do
    subject.gpg.must_equal ElectricSheep::Crypto::GPG
  end
end

describe ElectricSheep::Crypto::GPG do
  let(:keyfile) { 'path/to/key' }
  let(:executor) { mock }
  let(:gpg_regexp) { %r{gpg --batch --homedir \/tmp\/homedir} }
  let(:path_regexp) { %r{\/(?:[0-9a-zA-Z_-]+\/?)+} }
  let(:tempfile) { '/temp/file' }
  let(:ascii_armor) do
    "-----BEGIN PGP MESSAGE-----\n\nencrypted\n-----END PGP MESSAGE-----"
  end
  let(:binary) { 1 * 100 }

  it 'creates a string encryptor' do
    subject.string(executor)
      .must_be_instance_of ElectricSheep::Crypto::GPG::StringEncryptor
  end

  it 'creates a file encryptor' do
    subject.file(executor)
      .must_be_instance_of ElectricSheep::Crypto::GPG::FileEncryptor
  end

  def expects_exec(regexp, output)
    executor.expects(:exec)
      .with(regexp_matches(regexp))
      .returns(output)
  end

  def expects_keyid(type)
    options = '--batch --with-colons --fixed-list-mode --keyid-format 0xlong'
    expects_exec(%r{^gpg #{options} \/#{keyfile}},
                 exit_status: 0, out: "\n#{type}::::KEYID\n")
  end

  def expects_keyring
    ElectricSheep::Helpers::FSUtil
      .expects(:tempdir).with(executor).yields('/tmp/homedir')
  end

  def expects_key_import
    expects_exec(%r{^#{gpg_regexp} --import \/#{keyfile}}, exit_status: 0)
  end

  def operation_options(operation, options)
    "#{options}--no-version --#{operation} --always-trust -r KEYID"
  end

  class << self
    def ensure_exec_failure_raises
      it 'raises on command failure' do
        executor.expects(:exec).with(cmd = 'ls')
          .returns(exit_status: 1, err: 'An error')
        ex = -> { encryptor.send(:exec, cmd) }.must_raise RuntimeError
        ex.message.must_equal "Command failed to complete \"ls\": An error"
      end
    end

    def ensure_keyid_failure_raises
      it 'raises on key id retrieval failure' do
        executor.expects(:exec).returns(exit_status: 0, out: '')
        ex = -> { encryptor.send(:keyid, '/key') }.must_raise RuntimeError
        ex.message.must_equal 'Unable to retrieve key info for /key'
      end
    end
  end

  describe ElectricSheep::Crypto::GPG::StringEncryptor do
    let(:encryptor) { subject.new(executor) }

    def expects_operation(operation, output, options)
      ElectricSheep::Helpers::FSUtil.expects(:expand_path)
        .with(executor, keyfile).returns("/#{keyfile}")
      options = operation_options(operation, options)
      cmd = /^cat #{tempfile} \| #{gpg_regexp} #{options}$/
      expects_exec(cmd, exit_status: 0, out: output)
    end

    def expects_tempfile(contents)
      ElectricSheep::Helpers::FSUtil.expects(:tempfile).with(executor)
        .yields('/temp/file')
      cmd = "echo #{contents} > #{tempfile} && chmod 0700 #{tempfile}"
      executor.expects(:exec).with(cmd).returns(exit_status: 0)
    end

    def expects_encryption(_file, output, options = '')
      expects_tempfile('secret')
      expects_operation('encrypt', output, options)
    end

    def expects_decryption(_file, output, options = '')
      expects_tempfile(Shellwords.escape(ascii_armor))
      expects_operation('decrypt', output, options)
    end

    ensure_exec_failure_raises
    ensure_keyid_failure_raises

    describe 'with a keyring' do
      before do
        expects_keyring
        expects_key_import
      end

      describe 'encrypting' do
        before do
          expects_keyid('pub')
        end

        it 'encrypts plain text to binary' do
          expects_encryption(path_regexp, binary)
          encryptor.encrypt(keyfile, 'secret').must_equal binary
        end

        describe 'to ASCII-armored format' do
          before do
            expects_encryption(path_regexp, ascii_armor, '--armor ')
          end

          it 'outputs standard PGP message' do
            encryptor.encrypt(keyfile, 'secret', ascii: true)
              .must_equal ascii_armor
          end

          it 'compacts the output' do
            encryptor.encrypt(keyfile, 'secret', ascii: true, compact: true)
              .must_equal 'encrypted'
          end
        end
      end

      it 'decrypts the cipher text' do
        expects_keyid('sec')
        expects_decryption(path_regexp, 'secret')
        encryptor.decrypt(keyfile, 'encrypted').must_equal 'secret'
      end
    end
  end

  describe ElectricSheep::Crypto::GPG::FileEncryptor do
    let(:encryptor) { subject.new(executor) }
    %w(input output).each do |name|
      let(name) { "path/to/#{name}/file" }
    end

    ensure_exec_failure_raises
    ensure_keyid_failure_raises

    describe 'with a keyring' do
      before do
        [keyfile, input, output].each do |file|
          ElectricSheep::Helpers::FSUtil.expects(:expand_path)
            .with(executor, file).returns("/#{file}")
        end
        expects_keyring
        expects_key_import
      end

      describe 'encrypting' do
        def expects_operation(operation, input, output, options)
          options = operation_options(operation, options)
          cmd = %r{^cat \/#{input} \| #{gpg_regexp} #{options} > \/#{output}$}
          expects_exec(cmd, exit_status: 0)
        end

        def expects_encryption(input, output, options = '')
          expects_operation('encrypt', input, output, options)
        end

        def expects_decryption(input, output, options = '')
          expects_operation('decrypt', input, output, options)
        end

        describe 'encrypting' do
          before do
            expects_keyid('pub')
          end

          it 'encrypts plain text to binary' do
            expects_encryption(input, output)
            encryptor.encrypt(keyfile, input, output)
          end

          it 'outputs an ASCII-armored message' do
            expects_encryption(input, output, '--armor ')
            encryptor.encrypt(keyfile, input, output, ascii: true)
          end
        end

        it 'decrypts the cipher text' do
          expects_keyid('sec')
          expects_decryption(input, output)
          encryptor.decrypt(keyfile, input, output)
        end
      end
    end
  end
end
