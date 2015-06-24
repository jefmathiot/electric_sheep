module ElectricSheep
  module Helpers
    module FSUtil
      class << self
        TMPDIR = '/tmp'.freeze

        def tempname
          t = Time.now.strftime('%Y%m%d')
          "tmp#{t}-#{Process.pid}-#{rand(0x100000000).to_s(36)}"
        end

        def tempdir(executor, &block)
          path = expand_path(executor, File.join(TMPDIR, tempname))
          output = executor.exec("mkdir -p #{path} && chmod 0700 #{path}")
          fail 'Unable to create tempdir' if output[:exit_status] != 0
          yield_path(executor, path, &block)
        end

        def tempfile(executor, &block)
          path = expand_path(executor, File.join(TMPDIR, tempname))
          yield_path(executor, path, &block)
        end

        def expand_path(executor, path)
          executor.exec("echo \"#{path}\"")[:out]
        end

        def delete!(executor, path)
          executor.exec "rm -rf #{path}"
        end

        private

        def yield_path(executor, path, &_)
          if block_given?
            begin
              yield path
            ensure
              delete! executor, path
            end
          end
          path
        end
      end
    end
  end
end
