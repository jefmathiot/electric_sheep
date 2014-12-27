require 'spec_helper'

describe ElectricSheep::Notifier do

  NotifierKlazz = Class.new do
    include ElectricSheep::Notifier
  end

  describe NotifierKlazz do
    it 'makes initialization options available' do
      notifier = subject.new(project = mock, hosts=mock, logger=mock, metadata = mock)
      notifier.logger.must_equal logger
      notifier.project.must_equal project
      notifier.hosts.must_equal hosts
    end

  end

end
