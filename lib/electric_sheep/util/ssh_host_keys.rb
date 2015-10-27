require 'electric_sheep/spawn'
require 'fileutils'
require 'table_print'
require 'openssl'

module ElectricSheep
  module Util
    class SshHostKeys
      class << self
        include Helpers::ShellSafe

        def refresh(config, logger, force)
          keys = config.hosts.all.map do |_, host|
            fetch_server_keys(shell_safe(host.hostname), host.ssh_port, logger)
          end.flatten
          update_known_hosts(known_hosts(config), keys, force, logger)
        end

        private

        def update_known_hosts(known_hosts, keys, force, logger)
          unless force
            print_table(keys)
            print "Replace the public keys in \"#{known_hosts}\"? [Y/n]:"
            return unless STDIN.gets == 'Y'
          end
          remove_keys(known_hosts, keys.map { |key| key[:host] }.uniq, logger)
          append_keys(known_hosts, keys)
        end

        def known_hosts(config)
          File.expand_path(config.ssh_options.known_hosts)
        end

        def remove_keys(known_hosts, hosts, logger)
          return unless File.exist?(known_hosts)
          hosts.each do |hostname|
            cmd = "ssh-keygen -R -f #{known_hosts} -R #{hostname}"
            result = Spawn.exec(cmd, logger)
            next if result[:exit_status] == 0
            logger.warn "Unable to remove keys from \"#{known_hosts}\" " \
                        "for server #{hostname}"
            logger.warn result[:err]
          end
        end

        def append_keys(known_hosts, keys)
          unless File.exist?(known_hosts)
            FileUtils.touch known_hosts
            FileUtils.chmod 0600, known_hosts
          end
          File.open(known_hosts, 'ab') do |f|
            keys.each do |key|
              f.puts known_host_entry(key)
            end
          end
        end

        def known_host_entry(key)
          sha1 = OpenSSL::Digest.new('sha1')
          # 160 bits random-value, base-64 encoded
          salt = SecureRandom.random_bytes(20)
          hash = OpenSSL::HMAC.digest(sha1, salt, key[:host])
          salt_and_hash = ['|1', Base64.encode64(salt), Base64.encode64(hash)]
                          .map(&:chomp).join('|')
          "#{salt_and_hash} #{key[:keytype]} #{key[:key]}"
        end

        def print_table(keys)
          table_opts = [
            :host,
            :keytype,
            :size,
            fingerprint: { display_name: 'Fingerprint', width: 47 }
          ]
          printer = TablePrint::Printer.new(keys, table_opts)
          print 'The following public keys have been retrieved:'
          print printer.table_print
        end

        def print(str)
          STDOUT.puts str
        end

        def fetch_server_keys(host, port, logger)
          result = Spawn.exec("ssh-keyscan -p #{port} #{host}", logger)
          unless result[:exit_status] == 0
            logger.error result[:err]
            fail "Unable to fetch key for server #{host}"
          end
          parse_keys(result[:out])
        end

        def parse_keys(scan)
          scan.chomp.split("\n").map do |line|
            parts = line.split(' ')
            server_key = [:host, :keytype, :key]
                         .each_with_object({}) do |key, hsh|
              hsh[key] = parts.shift
            end
            fingerprint(server_key)
          end
        end

        def fingerprint(server_key)
          keyfile(server_key) do |file|
            parts = `ssh-keygen -lf #{file.path}`.chomp.split(' ')
            [:size, :fingerprint].each { |key| server_key[key] = parts.shift }
          end
          server_key
        end

        def keyfile(server_key, &_)
          Tempfile.new('ssh-keyfile').tap do |file|
            file.write "#{server_key[:keytype]} #{server_key[:key]}"
            file.close
            yield file
          end
        end
      end
    end
  end
end
