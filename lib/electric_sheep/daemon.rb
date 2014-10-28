module ElectricSheep
  class Daemon

    def initialize(options)
      @config = options[:config]
      @logger = options[:logger]
      @pidfile=File.expand_path(options[:pidfile])
    end

    def start!
      raise "Another daemon seems to be running" if running?
      pid=daemonize do
        loop do
          @config.all.each do |project|
            project.on_schedule do
              @logger.info "Forking a new process to handle project #{project.id}"
            end
          end
          # TODO Configurable rest time
          sleep 1
        end
      end
      write_pidfile(pid)
    end

    protected
    def write_pidfile(pid)
      @logger.info "Daemon started, pid: #{pid}"
      File.open(@pidfile, 'w') do |f|
        f.puts pid
      end
    end

    def running?
      if File.exists?(@pidfile)
        pid = File.read(@pidfile).chomp.to_i
        return true if process?(pid)
        @logger.warn "Removing pid file #{@pidfile} as the process with pid "+
          "#{pid} does not exist anymore"
        File.delete(@pidfile)
      end
      false
    end

    def process?(pid)
      pid > 0 && Process.kill(0, pid)
      rescue Errno::ESRCH, RangeError
        false
    end

    def daemonize(&block)
      reader, writer = IO.pipe
      fork do
        Process.daemon
        reader.close
        writer.puts Process.pid
        yield
      end
      reader.gets.to_i
    end

  end
end