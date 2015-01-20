module Support
  module Transport
    extend ActiveSupport::Concern
    include Options

    included do
      let(:job){ ElectricSheep::Metadata::Job.new(id: 'some-job') }
      let(:resource){ mock }
      let(:metadata){ mock }
      let(:logger){ mock }
      let(:hosts){ ElectricSheep::Metadata::Hosts.new }
    end
  end
end
