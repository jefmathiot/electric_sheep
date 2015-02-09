require 'spec_helper'

describe ElectricSheep::Crypto do

  it 'returns the GPG encryption module' do
    subject.gpg.must_equal ElectricSheep::Crypto::GPG
  end

end

describe ElectricSheep::Crypto::GPG do

  it 'creates a string encryptor' do
    subject.string.
      must_be_instance_of ElectricSheep::Crypto::GPG::StringEncryptor
  end

  it 'creates a file encryptor' do
    subject.file.
      must_be_instance_of ElectricSheep::Crypto::GPG::FileEncryptor
  end

  let(:keyfile){ 'path/to/key' }
  let(:keyfile_path){ File.expand_path(keyfile) }
  let(:spawn){ ElectricSheep::Spawn }
  let(:gpg_regexp){ /gpg --batch --homedir #{path_regexp}/ }
  let(:path_regexp){ /\/(?:[0-9a-zA-Z_-]+\/?)+/ }
  let(:ascii_armor){
    "-----BEGIN PGP MESSAGE-----\n\nENCRYPTED\n-----END PGP MESSAGE-----"
  }
  let(:binary){ 1 * 100 }

  def expects_exec(regexp, output)
    spawn.expects(:exec).
      with(regexp_matches(regexp)).
      returns(output)
  end

  def expects_keyid(type)
    options = "--batch --with-colons --fixed-list-mode --keyid-format 0xlong"
    expects_exec(/^gpg #{options} #{keyfile_path}/,
      exit_status: 0, out: "\n#{type}::::KEYID\n")
  end

  def expects_key_import
    expects_exec(/^#{gpg_regexp} --import #{keyfile_path}/,
    exit_status: 0)
  end

  def operation_options(operation, options)
    "#{options}--no-version --#{operation} --always-trust -r KEYID"
  end

  class << self

    def ensure_exec_failure_raises
      it 'raises on command failure' do
        spawn.expects(:exec).with(cmd='ls').
          returns(exit_status: 1, err: 'An error')
        ex = ->{ encryptor.send(:exec, cmd) }.must_raise RuntimeError
        ex.message.must_equal "GPG command failed to complete \"ls\": An error"
      end
    end

    def ensure_keyid_failure_raises
      it 'raises on key id retrieval failure' do
        spawn.expects(:exec).returns(exit_status: 0, out: '')
        ex = ->{ encryptor.send(:keyid, keyfile_path) }.must_raise RuntimeError
        ex.message.must_equal "Unable to retrieve key info for #{keyfile_path}"
      end
    end

  end

  describe ElectricSheep::Crypto::GPG::StringEncryptor do

    let(:encryptor){ subject.new }

    def expects_operation(operation, file, output, options)
      options = operation_options(operation, options)
      expects_exec(/^cat #{file} \| #{gpg_regexp} #{options}$/,
      exit_status: 0, out: output)
    end

    def expects_encryption(file, output, options='')
      expects_operation('encrypt', file, output, options)
    end

    def expects_decryption(file, output, options='')
      expects_operation('decrypt', file, output, options)
    end

    ensure_exec_failure_raises
    ensure_keyid_failure_raises

    describe 'encrypting' do

      before do
        expects_key_import
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
          encryptor.encrypt(keyfile, 'secret', ascii: true).must_equal ascii_armor
        end

        it 'compacts the output' do
          encryptor.encrypt(keyfile, 'secret', ascii: true, compact: true).
            must_equal "ENCRYPTED"
        end

      end

    end

    it 'decrypts the cipher text' do
      expects_key_import
      expects_keyid('sec')
      expects_decryption(path_regexp, 'secret')
      encryptor.decrypt(keyfile, 'encrypted').must_equal 'secret'
    end

  end

  describe ElectricSheep::Crypto::GPG::FileEncryptor do

    let(:encryptor){ subject.new }
    %w(input output).each do |name|
      let(name){ "/path/to/#{name}/file" }
    end

    ensure_exec_failure_raises
    ensure_keyid_failure_raises

    describe 'encrypting' do

      def expects_operation(operation, input, output, options)
        options = operation_options(operation, options)
        expects_exec(/^cat #{input} \| #{gpg_regexp} #{options} > #{output}$/,
          exit_status: 0)
      end

      def expects_encryption(input, output, options='')
        expects_operation('encrypt', input, output, options)
      end

      def expects_decryption(input, output, options='')
        expects_operation('decrypt', input, output, options)
      end


      describe 'encrypting' do

        before do
          expects_key_import
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
        expects_key_import
        expects_keyid('sec')
        expects_decryption(input, output)
        encryptor.decrypt(keyfile, input, output)
      end

    end

  end


end
