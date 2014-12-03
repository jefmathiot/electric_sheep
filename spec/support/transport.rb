module Support
  module Transport
    extend ActiveSupport::Concern
    include Options

    included do
      let(:project){ ElectricSheep::Metadata::Project.new(id: 'some-project') }
      let(:resource){ mock }
      let(:metadata){ mock }
      let(:logger){ mock }
      let(:hosts){ ElectricSheep::Metadata::Hosts.new }
    end
  end
end
