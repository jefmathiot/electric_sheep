require 'aruba/cucumber'
require 'pathname'
require 'colorize'
require_relative 'aruba/aruba_helper'

ENV['ELECTRIC_SHEEP_ENV'] = 'test'.freeze

module ElectricSheep
  module Acceptance
    attr_accessor :electric_dir

    def electric_sheep
      File.join(electric_dir, 'bin/electric_sheep')
    end

    def sheepfile
      @sheepfile || File.join(acceptance_dir, 'Sheepfile')
    end

    def acceptance_dir
      File.join(electric_dir, 'acceptance')
    end

    def timestamped_resource(resource)
      extension = File.extname(resource)
      path_items = [File.basename(resource, extension)]
      if Pathname.new(resource).absolute?
        path_items.unshift File.dirname(basename)
      end
      "#{File.join(path_items.compact)}-*-*#{extension}"
    end

    def assert_remote_file_exists?(path)
      ssh_run_simple("ls #{path}", timeout: 10)
    end

    def refute_remote_file_exists?(path)
      ssh_run_simple("ls #{path}", timout: 10)
      false
    rescue RSpec::Expectations::ExpectationNotMetError
      true
    end

    def refute_local_file_exists?(path)
      cd('.') do
        path = File.expand_path(path)
        expect(FileTest.exists?(path))
          .to be(false), "expected #{path} to be absent"
      end
    end

    def assert_local_file_exists?(path)
      cd('.') do
        path = File.expand_path(path)
        expect(FileTest.exists?(path))
          .to be(true), "expected #{path} to be present"
      end
    end

    def ssh_run_simple(cmd, timeout = nil)
      options = [
        '-o', 'StrictHostKeyChecking=no',
        '-o', 'PasswordAuthentication=no',
        '-o', 'UserKnownHostsFile=/dev/null',
        '-p', '2222',
        '-i', File.join(acceptance_dir, 'id_rsa')
      ]
      run_simple "ssh #{options.join(' ')} vagrant@127.0.0.1 \"#{cmd}\"",
                 fail_on_error: true, timeout: timeout
    end

    def with_multiple_files(directory, &_block)
      @files = [1, 2, 3].map do |index|
        "dummy.file.#{index}".tap do |file|
          yield directory, file
        end
      end
    end
  end
end

World(ElectricSheep::Acceptance)

Aruba.configure do |config|
  config.exit_timeout = 15
  config.working_directory = 'tmp'
end

Before do
  self.electric_dir = File.expand_path('.')
  ssh_run_simple 'rm -rf /tmp/acceptance /tmp/acceptance_backup'
  ssh_run_simple 'rm -rf /home/vagrant/.electric_sheep'
  FileUtils.rm_rf "#{`echo $HOME`.strip}/.electric_sheep/working-directories"
end
