require 'net/scp'

module ElectricSheep
  module Transports
    class SCP
      include Transport

      register as: "scp"

      def remote_interactor
        target_host=input.local? ? host(option(:to)) : input.host
        @remote_interactor ||= Interactors::SshInteractor.new(
          target_host, @project, option(:as), @logger
        )
      end

      def remote_resource
        send("#{input.type}_resource", host(option(:to)))
      end

      # def copy
      #   transfer :copy
      # end
      #
      # def move
      #   transfer :move
      # end
      #
      # private
      # def interactor_for(host)
      #   if host.local?
      #     local_interactor
      #   else
      #     Interactors::SshInteractor.new(host, @project, option(:as))
      #   end
      # end
      #
      # def transfer(operation)
      #   log(operation)
      #   operation_opts=Struct.new(:resource, :interactor)
      #   from=operation_opts.new(
      #     input,
      #     interactor_for(input.host)
      #   )
      #   target_host=host(option(:to))
      #   to=operation_opts.new(
      #     build_resource(target_host),
      #     interactor_for(target_host)
      #   )
      #   delete_source=operation==:move
      #   [DownloadOperation, UploadOperation].each do |op_klazz|
      #     op_klazz.new(from: from, to: to).perform(delete_source)
      #   end
      #   done! delete_source ? to.resource : from.resource
      # end
      #
      # def build_resource(target_host)
      #   send("#{input.directory? ? :directory : :file}_resource", target_host)
      # end
      #
      # class Operation
      #
      #   def initialize(options)
      #     @options=options
      #   end
      #
      #   protected
      #   def from
      #     @options[:from]
      #   end
      #
      #   def to
      #     @options[:to]
      #   end
      #
      #   def copy(target, action)
      #     send(
      #       from.resource.directory? ? :copy_directory : :copy_file,
      #       action,
      #       target.interactor
      #     )
      #   end
      #
      #   def copy_file(action, interactor)
      #     interactor.scp.send(
      #       "#{action}!",
      #       paths[:source],
      #       paths[:target]
      #     )
      #   end
      #
      #   def copy_directory(action, interactor)
      #     wrap_directory_copy do
      #       interactor.scp.send(
      #         "#{action}!",
      #         paths[:source],
      #         tmpdir,
      #         recursive: true
      #       )
      #     end
      #   end
      #
      #   def wrap_directory_copy(&block)
      #     to.interactor.exec "mkdir #{tmpdir}"
      #     yield
      #     to.interactor.exec "mv #{scp_target_dir} #{paths[:target]}"
      #     to.interactor.exec "rm -rf #{tmpdir}"
      #   end
      #
      #   def paths
      #     @paths ||= {
      #       source: from.interactor.expand_path(from.resource.path),
      #       target: to.interactor.expand_path(to.resource.path)
      #     }
      #   end
      #
      #   def scp_target_dir
      #     # net-scp copy a new "source" directory inside the target one
      #     File.join(tmpdir, File.basename(paths[:source]))
      #   end
      #
      #   def tmpdir
      #     t = Time.now.strftime("%Y%m%d")
      #     @tmpdir||=File.join(
      #       File.dirname(paths[:target]),
      #       "tmp#{t}-#{$$}-#{rand(0x100000000).to_s(36)}"
      #     )
      #   end
      #
      #   def delete_cmd
      #     "rm -rf #{paths[:source]}"
      #   end
      #
      # end
      #
      # class UploadOperation < Operation
      #
      #   def perform(delete_source, &block)
      #     return unless from.resource.host.local? && !to.resource.host.local?
      #     to.interactor.in_session do
      #       copy(to, :upload)
      #     end
      #     from.interactor.in_session do
      #       from.interactor.exec(delete_cmd) if delete_source
      #     end
      #   end
      #
      # end
      #
      # class DownloadOperation < Operation
      #
      #   def perform(delete_source, &block)
      #     return unless !from.resource.host.local? && to.resource.host.local?
      #     from.interactor.in_session do
      #       copy(from, :download)
      #       from.interactor.exec(delete_cmd) if delete_source
      #     end
      #   end
      #
      # end

    end
  end
end
