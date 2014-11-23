require 'spec_helper'

describe ElectricSheep::Notifier do

  NotifierKlazz = Class.new do
    include ElectricSheep::Notifier
  end

  describe NotifierKlazz do
    it 'makes initialization options available' do
      notifier = subject.new(project = mock, logger = mock, metadata = mock)
      notifier.logger.must_equal logger
    end

  end

end
