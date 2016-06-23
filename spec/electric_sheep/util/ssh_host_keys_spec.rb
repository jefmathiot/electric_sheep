require 'spec_helper'

describe ElectricSheep::Util::SshHostKeys do
  def read_file(name)
    File.read(File.join(File.dirname(__FILE__), name)).chomp
  end

  def read_pubkey(host, type)
    read_file("#{host}.#{type}.pub")
  end

  let(:scan_keys) do
    [
      [
        'host.one.tld ' << read_pubkey('host.one.tld', 'rsa'),
        'host.one.tld ' << read_pubkey('host.one.tld', 'ecdsa')
      ],
      [
        'host.two.tld ' << read_pubkey('host.two.tld', 'rsa')
      ]
    ]
  end

  let(:known_hosts_file) do
    Tempfile.new('known_hosts_file')
  end

  let(:known_hosts_file_path) do
    if known_hosts_file.respond_to?(:path)
      known_hosts_file.path
    else
      known_hosts_file
    end
  end

  let(:ssh_options) do
    ElectricSheep::Metadata::SshOptions.new(known_hosts: known_hosts_file_path)
  end

  after do
    known_hosts_file.unlink if known_hosts_file.respond_to?(:unlink)
  end

  let(:config) do
    ElectricSheep::Config.new.tap do |config|
      config.hosts.add('first-host', hostname: 'host.one.tld', ssh_port: 2222)
      config.hosts.add('second-host', hostname: 'host.two.tld')
      config.ssh_options = ssh_options
    end
  end

  let(:logger) { mock }

  def expects_keyscan(host, port, result)
    ElectricSheep::Spawn
      .expects(:exec)
      .with("ssh-keyscan -p #{port} #{host}", logger)
      .returns(result)
  end

  it 'fails when it\'s not able to scan a remote key' do
    expects_keyscan('host.one.tld', 2222, exit_status: 1, err: 'An error')
    logger.expects(:error).with('An error')
    ex = -> { subject.refresh(config, logger, false) }.must_raise
    ex.message.must_equal 'Unable to fetch key for server host.one.tld'
  end

  describe 'with keys scanned' do
    let(:confirmation_messages) do
      confirmation = /Replace the public keys in "#{known_hosts_file_path}"\?/
      header = /HOST\s+\| KEYTYPE\s+\| SIZE\s+\| FINGERPRINT\s+\n(-+\|){3}-+\n/
      hostname = /host\.(one|two)\.tld/
      key_type = /(ssh-rsa|ecdsa-sha2-nistp256)/
      key_size = /(256|2048)/
      hash = /(SHA256:\S{43}|(\w{2}:?){16})/
      host = /(#{hostname} \| #{key_type}\s+\| #{key_size}\s+\| #{hash}\n?)/

      [
        'The following public keys have been retrieved:',
        regexp_matches(/#{header}#{host}{3}/),
        regexp_matches(%r{#{confirmation} \[Y\/n\]:})
      ]
    end

    before do
      expects_keyscan('host.one.tld', 2222,
                      exit_status: 0, out: scan_keys.first.join("\n"))
      expects_keyscan('host.two.tld', 22,
                      exit_status: 0, out: scan_keys.last.join("\n"))
    end

    def expects_key_removal(hostname, success)
      if success
        result = { exit_status: 0 }
      else
        result = { exit_status: 1, err: 'An error' }
        err = /Unable to remove keys from \"#{known_hosts_file_path}\"/
        logger
          .expects(:warn)
          .with(regexp_matches(/#{err} for server #{hostname}/))
        logger.expects(:warn).with('An error')
      end
      ElectricSheep::Spawn
        .expects(:exec)
        .with(regexp_matches(/ssh-keygen -R -f .* #{hostname}/), logger)
        .returns(result)
    end

    def assert_valid_known_hosts
      File.read(known_hosts_file).tap do |contents|
        contents.split("\n").tap do |lines|
          lines.length.must_equal 3
          lines.each do |line|
            line.must_match(/\|1\|.*\|.* (ssh-rsa|ecdsa-sha2-nistp256) .*/)
          end
        end
      end
    end

    def expects_key_replacement(hostnames, success = true, force = false)
      STDIN.expects(:gets).returns('Y') unless force
      hostnames.each do |hostname|
        expects_key_removal hostname, success
      end
      subject.refresh(config, logger, force)
      assert_valid_known_hosts
    end

    describe 'forcing confirmation' do
      it 'replaces the keys' do
        expects_key_replacement(%w(host.one.tld host.two.tld), true, true)
      end
    end

    describe 'asking for confirmation' do
      before do
        confirmation_messages.each do |msg|
          STDOUT.expects(:puts).with(msg)
        end
      end

      it 'exits unless the user confirms replacement' do
        STDIN.expects(:gets).returns('n')
        subject.refresh(config, logger, false)
      end

      it 'replaces the keys' do
        expects_key_replacement(%w(host.one.tld host.two.tld))
      end

      it 'warns if it is not able to remove keys' do
        expects_key_replacement(%w(host.one.tld host.two.tld), false)
      end

      describe 'when the known hosts file does not exist' do
        let(:known_hosts_file) do
          file = Tempfile.new('known_hosts_file')
          file.path.tap do
            file.unlink
          end
        end

        it 'only appends keys if known hosts file does not exist' do
          STDIN.expects(:gets).returns('Y')
          subject.refresh(config, logger, false)
          assert_valid_known_hosts
        end
      end
    end
  end
end
