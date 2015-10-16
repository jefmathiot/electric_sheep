module ElectricSheep
  class Master
    attr_reader :spawners, :should_stop

    def initialize(options)
      @config = options[:config]
      @logger = options[:logger]
      @workers = [1, options[:workers]].compact.max
      @pidfile = File.expand_path(options[:pidfile]) if options[:pidfile]
      @spawners = Spawners.get(options, @logger, @pidfile)
    end

    def start!
      fail 'Another master seems to be running' if running?
      @logger.info 'Starting master'
      spawners.master.spawn('Master started') do
        trap_signals
        until should_stop
          run_workers
          # TODO: Configurable rest time
          sleep 1
        end
      end
    end

    def stop!
      @logger.info 'Stopping master'
      kill_self
    end

    def restart!
      stop!
      start!
    end

    def running?
      pid = spawners.master.read_pidfile
      if pid
        return pid if process?(pid)
        @logger.warn "Removing pid file #{@pidfile} as the process with pid " \
          "#{pid} does not exist anymore"
        spawners.master.delete_pidfile
      end
      nil
    end

    protected

    def run_workers
      @logger.debug 'Searching for scheduled jobs'
      run_scheduled
      flush_workers
    end

    def trap_signals
      trap(:TERM) { @should_stop = true }
    end

    def kill_self
      return unless (pid = running?)
      @logger.debug "Terminating process #{pid}"
      Process.kill(15, pid)
      spawners.master.delete_pidfile
    end

    def process?(pid)
      pid > 0 && Process.kill(0, pid)
    rescue Errno::ESRCH, RangeError
      false
    end

    def run_scheduled
      @config.iterate do |job|
        if worker_pids.size < @workers
          job.on_schedule do
            run_job(job)
          end
        end
      end
    end

    def run_job(job)
      log_run(job) do
        worker = spawners.worker.spawn do
          Runner::SingleRun.new(@config, @logger, job).run!
        end
        worker_pids[worker] = job.id
        worker
      end
    end

    def log_run(job, &_)
      @logger.info "Forking a new worker to handle job \"#{job.id}\""
      pid = yield
      @logger.debug "Forked a worker for job \"#{job.id}\", pid: #{pid}"
    end

    def flush_workers
      worker_pids.each do |pid, job|
        unless process?(pid)
          worker_pids.delete(pid)
          @logger.info "Worker for job \"#{job}\" completed, pid: #{pid}"
        end
      end
      @logger.debug "Active workers: #{worker_pids.size}"
    end

    def worker_pids
      @worker_pids ||= {}
    end

    class Spawners
      class << self
        def get(options, logger, pidfile)
          struct = Struct.new(:master, :worker)
          if options[:daemon]
            master = DaemonSpawner.new(logger, pidfile)
            worker = DaemonSpawner.new(logger)
          else
            master = InlineSpawner.new(logger)
            worker = ForkSpawner.new(logger)
          end
          struct.new(master, worker)
        end
      end
    end

    class ProcessSpawner
      def initialize(logger, pidfile = nil)
        @logger = logger
        @pidfile = pidfile
      end

      def read_pidfile
        if @pidfile && File.exist?(@pidfile)
          return File.read(@pidfile).chomp.to_i
        end
        nil
      end

      def delete_pidfile
        File.delete(@pidfile) if @pidfile && File.exist?(@pidfile)
      end

      private

      def write_pidfile(pid)
        return unless @pidfile
        File.open(@pidfile, 'w') do |f|
          f.puts pid
        end
      end

      def done(banner, pid)
        write_pidfile(pid)
        announce(banner, pid)
        pid
      end

      def announce(banner, pid)
        @logger.info "#{banner}, pid: #{pid}" if banner
      end
    end

    class DaemonSpawner < ProcessSpawner
      def spawn(banner = nil, &_)
        reader, writer = IO.pipe
        fork_pid = fork do
          Process.daemon
          reader.close
          writer.puts Process.pid
          yield
        end
        # Detach fork to avoid zombie processes
        Process.detach(fork_pid)
        done(banner, reader.gets.to_i)
      end
    end

    class ForkSpawner < ProcessSpawner
      def spawn(banner = nil, &_)
        fork_pid = fork do
          yield
        end
        # Detach fork to avoid zombie processes
        Process.detach(fork_pid)
        done(banner, fork_pid)
      end
    end

    class InlineSpawner < ProcessSpawner
      def spawn(banner = nil, &_)
        done(banner, Process.pid)
        yield
      end
    end
  end
end
