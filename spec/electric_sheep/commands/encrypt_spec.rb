require 'spec_helper'
require 'json'

describe ElectricSheep::Commands::Encrypt do
  include Support::Command

  it{
    defines_options :public_key
  }

  let(:spawn){ ElectricSheep::Spawn }
  let(:fs_util){ ElectricSheep::Helpers::FSUtil }
  let(:gpg){ ElectricSheep::Crypto.gpg }
  let(:seq){ sequence('encryption') }
  let(:shell){ mock }

  ensure_registration "encrypt"

  def expects_log ; end

  def expects_key_conversion(status = 0)
    # Key copy
    fs_util.expects(:tempfile).in_sequence(seq).with(shell).twice.
      yields('/tmp/keyfile').then.yields('/tmp/ascii')
    spawn.expects(:exec).in_sequence(seq).
      with("gpg --batch --enarmor < \"/path/to/key\"").
      returns(exit_status: status, out: "ARMORED ASCII")
  end

  executing do
    let(:output_name){ "file-20140605-040302" }
    let(:output_ext){ ".gpg" }
    let(:output_type){:file}
    let(:input){ file("/tmp/file") }

    it 'encrypts the provided input' do
      metadata.stubs(:public_key).returns('/path/to/key')
      shell.expects(:expand_path).at_least(1).with(input.path).
        returns(input.path)
      # Initial steps
      expects_stat(:file, input, 4096)
      logger.expects(:info).in_sequence(seq).with("Encrypting \"file\"")
      # Key copy
      expects_key_conversion
      cmds = ["echo \"ARMORED ASCII\" > /tmp/ascii"]
      cmds << "gpg --batch --dearmor < /tmp/ascii > /tmp/keyfile"
      # Final call
      gpg.expects(:file).with(shell).returns(encryptor = mock)
      encryptor.expects(:encrypt).with('/tmp/keyfile', input.path, output_path)
      ensure_execution(*cmds)
    end

  end

  it 'raises when unable to convert public key to the ASCII-armored format' do
    input = mock(basename: 'file')
    metadata = mock(public_key: '/path/to/key')
    command = subject.new(nil, logger = mock, shell, input, metadata)
    command.stubs(:host).returns(host='host')
    logger.expects(:info).in_sequence(seq).with("Encrypting \"file\"")
    command.expects(:file_resource).in_sequence(seq).
      with(host, extension: '.gpg').yields(mock)
    expects_key_conversion(1)
    ex = ->{ command.perform! }.must_raise RuntimeError
    ex.message.must_match /^Unable to convert the public key/
  end

end
