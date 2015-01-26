require 'spec_helper'

describe ElectricSheep::Crypto do
end

describe ElectricSheep::Crypto::OpenSSL do

  def encode64s(string)
    Base64.encode64(string).gsub /\n/, ''
  end

  describe 'encrypting' do

    def expects_encryption(successful = true)
      OpenSSL::PKey::RSA.expects(:new).with(pem_lines).returns(key = mock)
      key.expects(:public?).returns(successful)
      if successful
        key.expects(:public_encrypt).with('PLAIN').returns('CIPHER')
        subject.encrypt('PLAIN', key_file.path).must_equal encode64s('CIPHER')
      else
        ->{subject.encrypt('PLAIN', key_file.path)}.must_raise RuntimeError,
          /Not a public key/
      end
    end

    let(:pem_lines){
      "-----BEGIN RSA PUBLIC KEY-----\n" +
      "XXXXXX\n" +
      "-----END RSA PUBLIC KEY-----"
    }

    describe 'with a key in the OpenSSH format' do
      let(:exec_result) do
        pem_lines
      end

      let(:spawn) do
        ElectricSheep::Spawn
      end

      let(:key_file) {
        Tempfile.new('encryption-key').tap do |f|
          f.write 'ssh-rsa XXXXXXX'
          f.close
        end
      }

      def expects_conversion(status)
        spawn.expects(:exec).
          with("ssh-keygen -f #{key_file.path} -e -m pem").
          returns({out: exec_result, err: "An error", exit_status: status})
      end

      it 'encrypts the plain text' do
        expects_conversion(0)
        expects_encryption
      end

      it 'raises if it where unable to convert key' do
        expects_conversion(1)
        ->{subject.encrypt('PLAIN', key_file.path)}.must_raise RuntimeError,
          /Unable to convert key file/
      end

      it 'raises if key is not public' do
        expects_conversion(0)
        expects_encryption(false)
      end

    end

    describe 'with a key in the RSA format' do

      let(:key_file) {
        Tempfile.new('encryption-key').tap do |f|
          f.write pem_lines
          f.close
        end
      }

      it 'encrypts the plain text' do
        expects_encryption
      end

      it 'raises if key is not public' do
        expects_encryption(false)
      end

    end

    it 'raises if key file not found' do
      ->{subject.encrypt('', '/not/a/file')}.must_raise RuntimeError,
        /Key file not found/
    end

    it 'raises if format is not supported' do
      key_file = Tempfile.new('bad-key').tap do |f|
        f.write 'XXXXXXXXX'
        f.close
      end
      ->{subject.encrypt('', key_file.path)}.must_raise RuntimeError,
        /Key file format not supported/
    end

  end

  describe 'decrypting' do
    let(:pem_lines){ [
      "-----BEGIN RSA PRIVATE KEY-----\n",
      "XXXXXX\n",
      "-----END RSA PRIVATE KEY-----\n"
    ] }

    let(:key_file) {
      Tempfile.new('encryption-key').tap do |f|
        f.write pem_lines.join
        f.close
      end
    }

    def expects_decryption(successful = true)
      OpenSSL::PKey::RSA.expects(:new).with(pem_lines.join).returns(key = mock)
      key.expects(:private?).returns(successful)
      if successful
        key.expects(:private_decrypt).with('CIPHER').returns('PLAIN')
        subject.decrypt(encode64s('CIPHER'), key_file.path).must_equal 'PLAIN'
      else
        ->{subject.decrypt(encode64s('CIPHER'), key_file.path)}.must_raise RuntimeError,
          /Not a private key/
      end
    end

    it 'encrypts the plain text' do
      expects_decryption
    end

    it 'raises if key is not private' do
      expects_decryption(false)
    end

    it 'raises if key file not found' do
      ->{subject.decrypt('', '/not/a/file')}.must_raise RuntimeError,
        /Key file not found/
    end

    it 'raises if format is not supported' do
      key_file = Tempfile.new('bad-key').tap do |f|
        f.write 'XXXXXXXXX'
        f.close
      end
      ->{subject.decrypt('', key_file.path)}.must_raise RuntimeError,
        /Key file format not supported/
    end

  end
end
