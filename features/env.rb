require 'aruba/cucumber'

module ElectricSheep
  module Acceptance

    attr_accessor :electric_dir

    def electric_sheep
      File.join(electric_dir, 'bin/electric_sheep')
    end

    def sheepfile
      File.join(acceptance_dir, 'Sheepfile')
    end

    def acceptance_dir
      File.join(electric_dir, 'acceptance')
    end

    def assert_remote_file_exists?(path)
      ssh_run_simple("test -s #{path}", 10)
    end

    def refute_local_file_exists?(path)
      in_current_dir do
        path = File.expand_path(path)
        expect(FileTest.exists?(path)).to be(false), "expected #{path} to be absent"
      end
    end
    
    def ssh_run_simple(cmd, timeout=nil)
      options=[
        '-o', 'StrictHostKeyChecking=no',
        '-o', 'UserKnownHostsFile=/dev/null',
        '-p', '2222'
      ]
      run_simple "ssh #{options.join(' ')} vagrant@127.0.0.1 \"#{cmd}\""
    end
  end
end

World(ElectricSheep::Acceptance)

Before do
  self.electric_dir=File.expand_path('.')
end

