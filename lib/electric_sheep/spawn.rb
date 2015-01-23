require 'posix/spawn'

module ElectricSheep

  module Spawn

    def self.exec(cmd, logger=nil)
      result = {out: '', err: ''}
      child = POSIX::Spawn::Child.new(cmd)
      unless child.out.nil?
        result[:out] = child.out.chomp
        logger.debug result[:out] if logger
      end
      unless child.err.nil?
        result[:err] = child.err.chomp
      end
      result[:exit_status]=child.status
      result
    end

  end

end
